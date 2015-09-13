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
            my $meta_client = MetaCPAN::Client->new();
    
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

get '/info/:pkg' => sub {

    my $c = shift;
    my $pkg = $c->stash('pkg');

    my $meta_client = MetaCPAN::Client->new();
    
    my $m = $meta_client->module($pkg);

    $c->stash('doc' => $m->pod('html'));

} => 'pkg_info';

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
            <th>package</th>
            <th>info</th>
            <th>install</th>
            <th>author</th>
        </tr>
    </thead>
    <tbody>
    <% foreach my $p (@{$list}) { %>
    <tr>
        <td><a href="/info/<%= $p->{name} %>"><%= $p->{release}  %></a></td>
        <td><%= $p->{info} %></td>
        <td><span class="label label-default">cpanm <%= $p->{name} %></span></td>
        <td><a href="mailto:<%= join "", @{$p->{email}} %>"><%= $p->{author}  %></a></td>
    </tr>
    <% } %>
    <tbody>
    </table>
    <% } %>

<!--
    Debug Info
    Packages found:<%= $count  %>
-->

@@ pkg_info.html.ep
%= bootstrap 'all'
%== app_header

<script src="https://ajax.googleapis.com/ajax/libs/jquery/1.11.3/jquery.min.js"></script>
<script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.5/js/bootstrap.min.js"></script>
<script type="text/javascript">
$(document).ready(function(){ 
    $("#myTab li:eq(1) a").tab('show');
});
</script>
<style type="text/css">
    .bs-example{
        margin: 20px;
    }
</style>
</head>
<body>
<div class="bs-example">
    <ul class="nav nav-tabs" id="myTab">
        <li><a data-toggle="tab" href="#sectionA">Documentation</a></li>
        <li><a data-toggle="tab" href="#sectionB">Section B</a></li>
        <li class="dropdown">
            <a data-toggle="dropdown" class="dropdown-toggle" href="#">Dropdown <b class="caret"></b></a>
            <ul class="dropdown-menu">
                <li><a data-toggle="tab" href="#dropdown1">Dropdown1</a></li>
                <li><a data-toggle="tab" href="#dropdown2">Dropdown2</a></li>
            </ul>
        </li>
    </ul>
    <div class="tab-content">
        <div id="sectionA" class="tab-pane fade in active">
            <h3>Documentation</h3>
            <%== $doc %>
        </div>
        <div id="sectionB" class="tab-pane fade">
            <h3>Section B</h3>
            <p>Vestibulum nec erat eu nulla rhoncus fringilla ut non neque. Vivamus nibh urna, ornare id gravida ut, mollis a magna. Aliquam porttitor condimentum nisi, eu viverra ipsum porta ut. Nam hendrerit bibendum turpis, sed molestie mi fermentum id. Aenean volutpat velit sem. Sed consequat ante in rutrum convallis. Nunc facilisis leo at faucibus adipiscing.</p>
        </div>
        <div id="dropdown1" class="tab-pane fade">
            <h3>Dropdown 1</h3>
            <p>WInteger convallis, nulla in sollicitudin placerat, ligula enim auctor lectus, in mollis diam dolor at lorem. Sed bibendum nibh sit amet dictum feugiat. Vivamus arcu sem, cursus a feugiat ut, iaculis at erat. Donec vehicula at ligula vitae venenatis. Sed nunc nulla, vehicula non porttitor in, pharetra et dolor. Fusce nec velit velit. Pellentesque consectetur eros.</p>
        </div>
        <div id="dropdown2" class="tab-pane fade">
            <h3>Dropdown 2</h3>
            <p>Donec vel placerat quam, ut euismod risus. Sed a mi suscipit, elementum sem a, hendrerit velit. Donec at erat magna. Sed dignissim orci nec eleifend egestas. Donec eget mi consequat massa vestibulum laoreet. Mauris et ultrices nulla, malesuada volutpat ante. Fusce ut orci lorem. Donec molestie libero in tempus imperdiet. Cum sociis natoque penatibus et magnis dis parturient.</p>
        </div>
    </div>
</div>
</body>
</html>                                     
