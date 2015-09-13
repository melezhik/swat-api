#!/usr/bin/env perl

use strict;
use Mojolicious::Lite;

use CHI;
use WWW::Mechanize::Cached;
use HTTP::Tiny::Mech;
use MetaCPAN::Client;
use Data::Dumper;

plugin 'BootstrapHelpers';

get '/' => 'search_form';

get '/search' => sub {

    my $c = shift;

    my $sq = $c->param('search_query');

    my $cache = CHI->new( driver => 'Memory', global => 1 );

    open F, "pkg.list" or die $!;

    my @list = ();

    while (my $pkg = <F> ){

        chomp $pkg;
        next unless $pkg=~/\S/;
        s/\s//g for $pkg;

        my $re = $sq ? qr/$sq/i : qr/.*/;

        if ($pkg =~ $re){
            
            app->log->debug("pkg $pkg is listed");
            my $meta_client = MetaCPAN::Client->new(
              ua => HTTP::Tiny::Mech->new(
                mechua => WWW::Mechanize::Cached->new(
                  cache => CHI->new(
                    driver   => 'File',
                    root_dir => "$ENV{HOME}/.swatman/metacpan/cache/",
                  ),
                ),
              ),
            );
    
            eval {

                my $pkg_cached = $cache->get($pkg);
    
                app->log->debug("$pkg cached: ".($pkg_cached ? 'YES' : 'NO' ));
                my $m = $meta_client->module($pkg)   unless $pkg_cached;
                my $a = $meta_client->author($m->author) unless $pkg_cached;

                #my $pod_cut = join "\n", ((split "\n", $m->pod())[0..5]);


                push @list, my $aa = {
                    name            => $pkg ,
                    author          => $cache->get($pkg.'::name') || $a->name,
                    email           => $cache->get($pkg.'::email') || $a->email,
                    release         => $cache->get($pkg.'::release') || $m->release,
                    info            => $cache->get($pkg.'::info') || $m->abstract,
                };
                unless ($pkg_cached) {   
                    for my $k (keys %$aa){
                        app->log->debug("set cache for ".( $pkg.'::'.$k  ));
                        $cache->set($pkg.'::'.$k , $aa->{$k}||'?');
                    }
                    $cache->set( $pkg, 1);
                }
            };
            app->log->debug("$pkg found on cpanmeta");
    
            if ($@){
                app->log->error("cpanmeta client error: $@");
                app->log->error("$pkg not found on cpanmeta");
                # TODO: handle cpanmeta related exeptions here
            }
    
        }
    

    } # next line in pkg.list

    close F;

    $c->stash(list => \@list );
    $c->stash(count => scalar @list );

} => 'search_results';

helper app_header => sub {
    qq{<head><title>Swatman - Swat Packages Repository</title></head>}
};

app->start;
__DATA__

@@ search_form.html.ep
%= bootstrap 'all'
%== app_header
    
<div class="panel-body">Search Swat Packages!

    %= form_for search => begin
      %= text_field 'search_query'
      %= submit_button 'Go'
    % end
    
</div>

@@ search_results.html.ep
%= bootstrap 'all'
%== app_header


    <div class="panel panel-default">
        <div class="panel-body">Packages found: <strong><%= $count  %></strong></div>
    </div>
    <% if ($count) { %>
    <table class="table">
    <thead>
        <tr>
            <th>name</th>
            <th>author</th>
            <th>info</th>
            <th>install</th>
        </tr>
    </thead>
    <tbody>
    <% foreach my $p (@{$list}) { %>
    <tr>
        <td> <%= $p->{release}  %></td>
        <td><a href="mailto:<%= join "", @{$p->{email}} %>"><%= $p->{author}  %></a></td>
        <td><%= $p->{info} %></td>
        <td><span class="label label-default">cpanm <%= $p->{name} %></span></td>
    </tr>
    <% } %>
    <tbody>
    </table>
    <% } %>

<!--
    Debug Info
    Packages found:<%= $count  %>
-->

