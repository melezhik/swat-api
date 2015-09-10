#!/usr/bin/env perl
use Mojolicious::Lite;
use MetaCPAN::Client;
use strict;

# Documentation browser under "/perldoc"
plugin 'PODRenderer';
plugin 'BootstrapHelpers';

get '/' => sub {
    my $c = shift;

    my $list = [];
    open F, "pkg.list" or die $!;
    while (my $l = <F> ){
        chomp $l;
        push @$list, $l;
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
    </tr>
</thead>
<tbody>
<% foreach my $i (@$list) { %>
<tr>
    <% chomp $i; %>
    <td><%= $i %></td>
</tr>
<% } %>
<tbody>
</table>

