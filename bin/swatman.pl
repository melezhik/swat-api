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

% title 'Green';
% layout 'green';
%= bootstrap 'all'


<h1>Swat Packages List</h1>

<%= @{$list} %> packages found:
<table>
<th>name</th>
<% foreach my $i (@$list) { %>
<tr>
    <% chomp $i; %>
    <td><%= $i %></td>
</tr>
<% } %>
</table>

