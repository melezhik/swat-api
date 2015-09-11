#!/usr/bin/env perl

use strict;
use Mojolicious::Lite;

use CHI;
use WWW::Mechanize::Cached;
use HTTP::Tiny::Mech;
use MetaCPAN::Client;


plugin 'BootstrapHelpers';

get '/' => 'search_form';

get '/search' => sub {

    my $c = shift;

    my $pkg = $c->param('search_query');


    open F, "pkg.list" or die $!;
    my $pkg_listed;
    while (my $l = <F> ){

        chomp $l;
        next unless $l=~/\S/;
        s/\s//g for $l;
        $pkg_listed = 1 if $l eq $pkg;

    }

    close F;


    if ($pkg_listed){
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

            $c->stash(pkg_found => 1);
            $c->stash(pkg_version => $m->version);
            $c->stash(pkg_author => $m->author);
            $c->stash(pkg_abstract => $m->abstract);

            #NAME        => $module->name,
            #ABSTRACT    => $module->abstract,
            #DESCRIPTION => $module->description,
            #RELEASE     => $module->release,
            #AUTHOR      => $module->author,
            #VERSION     => $module->version,
        };

        if ($@){
            $c->stash(pkg_found => 0);
            app->log->error("$pkg not found on cpanmeta");
            # TODO: handle cpanmeta related exeptions here
        }

    }else{
        app->log->debug("pkg $pkg is not listed");
    }

} => 'pkg_info';

helper app_title => sub {
    '<head><title>Swatman - Swat Packages Repository</title></head>'
};

app->start;
__DATA__

@@ search_form.html.ep
%= app_title
%= bootstrap 'all'

<div class="panel-body">Search Swat Packages

    %= form_for search_query => begin
      %= text_field 'search_query'
      %= submit_button 'Go'
    % end
    
</div>

@@ pkg_info.html.ep
%= app_title
%= bootstrap 'all'

<div class="panel panel-default">
    <div class="panel-body">Swat Packages List. Packages found: <%= @{$list} %></div>
</div>

<table class="table">
<thead>
    <tr>
        <th>name</th>
        <th>found at metacpan</th>
        <th>version</th>
    </tr>
</thead>
<tbody>
<% foreach my $i (@$list) { %>
<tr>
    <td><%= $i->{NAME} %></td>
    <td><%= $i->{FOUND} %></td>
    <td><%= $i->{VERSION} %></td>
</tr>
<% } %>
<tbody>
</table>


