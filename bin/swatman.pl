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

    my $pkg = $c->param('search_query');


    open F, "pkg.list" or die $!;

    my @list = ();

    while (my $l = <F> ){

        chomp $l;
        next unless $l=~/\S/;
        s/\s//g for $l;

        my $re = qr/$pkg/;

        if ($l =~ $re){

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
    
                my $m = $meta_client->module($pkg);
                push @list, {
                    version => $m->version ,
                    author => $m->author,
                    abstract => $m->abstract,
                    description => $m->description,
                    release => $m->release,
                }
    
                #NAME        => $module->name,
                #ABSTRACT    => $module->abstract,
                #DESCRIPTION => $module->description,
                #RELEASE     => $module->release,
                #AUTHOR      => $module->author,
                #VERSION     => $module->version,
            };
    
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

app->start;
__DATA__

@@ search_form.html.ep
%= bootstrap 'all'
<head><title>Swatman - Swat Packages Repository</title></head>
    
<div class="panel-body">Search Swat Packages

    %= form_for search => begin
      %= text_field 'search_query'
      %= submit_button 'Go'
    % end
    
</div>

@@ search_results.html.ep
%= bootstrap 'all'
<head><title>Swatman - Swat Packages Repository</title></head>


    <div class="panel panel-default">
        <div class="panel-body">Packages found: <strong><%= $count  %></strong></div>
    </div>
    <% if ($count) { %>
    <table class="table">
    <thead>
        <tr>
            <th>name</th>
            <th>author</th>
            <th>version</th>
            <th>abstract</th>
        </tr>
    </thead>
    <tbody>
    <% foreach my $p (@{$list}) { %>
    <tr>
        <td> <%= $p->{name}  %></td>
        <td> <%= $p->{author}  %></td>
        <td> <%= $p->{version} %></td>
        <td> <%= $p->{abstract} %></td>
    </tr>
    <% } %>
    <tbody>
    </table>
    <% } %>

<!--
    Debug Info
    Packages found:<%= $count  %>
-->
