#!/usr/bin/env perl

use strict;
use Mojolicious::Lite;
use Time::Piece;
use Mojo::Date;

use CHI;
use MetaCPAN::Client;
use Data::Dumper;

plugin 'BootstrapHelpers';

get '/' => 'home_page';

get '/about' => 'about_page';

get '/add-pkg' => 'add_pkg_page';

get '/faq' => 'faq_page';
   
get '/search' => sub {

    my $c = shift;

    my $sq = $c->param('search_query');

    $c->stash(query => $sq);

    open F, "pkg.list" or die $!;

    my @list = ();

    while (my $pkg = <F> ){

        chomp $pkg;
        next unless $pkg=~/\S/;
        s/\s//g for $pkg;

        my $re = $sq ? qr/$sq/i : qr/.*/;

        if ($pkg =~ $re){
            
            app->log->debug("pkg $pkg is listed");

    
            eval {
                push @list, (_save_meta_to_cache($c, $pkg));                
            };
            if ($@){
                app->log->error("metacpan client error: $@");
                app->log->error("$pkg failed to download from metacpan");
                # TODO: handle cpanmeta related exeptions here
            }
    
        }
    

    } # next line in pkg.list

    close F;

    $c->stash(list => \@list );
    $c->stash(count => scalar @list );

} => 'search_results';

get '/info/:pkg' => sub {

    my $c = shift;
    my $pkg = $c->stash('pkg');

    my $d = _save_meta_to_cache($c, $pkg);                

    for my $k (keys %$d) {
        $c->stash( $k => $d->{$k});
    }
    

} => 'pkg.info';


sub _metacpan_cache {

    CHI->new( driver => 'File', global => 1, root_dir => "$ENV{HOME}/.swatman/cache/metacpan" );

}

sub _save_meta_to_cache {

    my $c = shift;
    my $pkg = shift;

    my $cache = _metacpan_cache($pkg);

    $c->stash('pkg' => $pkg );

    my $meta_client = MetaCPAN::Client->new();

    my $pkg_cached = $cache->get($pkg);

    app->log->debug("$pkg cached: ".($pkg_cached ? 'YES' : 'NO' ));

    my $m = $meta_client->module($pkg)   unless $pkg_cached;
    my $a = $meta_client->author($m->author) unless $pkg_cached;
    my $r = $meta_client->release($m->distribution) unless $pkg_cached;


    my $meta = {
        name            => $pkg ,
        author          => $cache->get($pkg.'::author')     || $a->name,
        email           => $cache->get($pkg.'::email')      || $a->email,
        version         => $cache->get($pkg.'::version')    || $m->version,
        release         => $cache->get($pkg.'::release')    || $m->release,
        info            => $cache->get($pkg.'::info')       || $r->abstract,
        pod_html        => $cache->get($pkg.'::pod_html')   || $m->pod('html'),
        date            => $cache->get($pkg.'::date')       || Time::Piece->strptime(Mojo::Date->new($m->date)->to_string)->strftime("%a, %d %b %Y"),
        dist            => $cache->get($pkg.'::dist')       || $m->distribution,
        doc             => $cache->get($pkg.'::doc')        || $m->pod('html'),
        gravatar_url    => $cache->get($pkg.'::gravatar_url')  || $a->gravatar_url,
    };

    use DateTime;

    unless ($pkg_cached) {   
        for my $k (keys %$meta){
            app->log->debug("set cache for ".( $pkg.'::'.$k  ));
            $cache->set($pkg.'::'.$k , $meta->{$k}||'?');
        }
        $cache->set( $pkg, 1);
    }

    my $tap_f = "tap_samples/".($cache->get($pkg.'::dist')).'.txt';
    if (-e  $tap_f ){
        $meta->{'has_tap_out'} = 1;
        $cache->set($pkg.'::has_tap_out', 1);

        open my $tf , $tap_f or die $!;
        my $tout = join "", <$tf>;
        close $tf;

        $meta->{'tap_out'} = $tout;
        $cache->set($pkg.'::tap_out', $tout);

        app->log->debug("set cache for has_tap_out to 1");

    }else{
        $meta->{'has_tap_out'} = 0;
        $cache->set($pkg.'::has_tap_out', 0);

        $meta->{'tap_out'} = '';
        $cache->set($pkg.'::tap_out', '');

        app->log->debug("set cache for has_tap_out to 0");
        
    }

    app->log->debug("$pkg data downloaded from metacpan") unless $pkg_cached;

    return $meta
}

app->start;

