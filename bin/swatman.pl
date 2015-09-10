#!/usr/bin/env perl

use strict;
use Mojolicious::Lite;

use CHI;
use WWW::Mechanize::Cached;
use HTTP::Tiny::Mech;
use MetaCPAN::Client;


plugin 'BootstrapHelpers';

get '/' => sub {
    my $c = shift;

    my $list = [];

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

    open F, "pkg.list" or die $!;
    while (my $l = <F> ){

        chomp $l;


        my %data = ( NAME => $l, FOUND => '0' , VERSION => '?' );
        eval {
            my $module = $meta_client->module($l);
            $data{VERSION} = $module->version;
            $data{FOUND} = 1;
            #NAME        => $module->name,
            #ABSTRACT    => $module->abstract,
            #DESCRIPTION => $module->description,
            #RELEASE     => $module->release,
            #AUTHOR      => $module->author,
            #VERSION     => $module->version,
        };

        if ($@){
            # TODO: handle metacpan related exeptions here
        }

        push @$list, \%data;
    }
    close F;
    $c->render(template => 'index', list => $list );
};

app->start;
__DATA__

@@ index.html.ep

%= bootstrap 'all'


<div class="panel panel-default">
    <div class="panel-body">Swat Packages List. Packages found: <%= @{$list} %></div>
</div>

<table class="table">
<thead>
    <tr>
        <th>name</th>
        <th>metacpan found</th>
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

