#!/usr/bin/env perl
use Mojolicious::Lite;
use MetaCPAN::Client;
use strict;

# Documentation browser under "/perldoc"
plugin 'PODRenderer';

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
<%= @{$list} %> packages found:
<% for my $i ( each @$list) { %>
    <%= $i %>
<% } %>

