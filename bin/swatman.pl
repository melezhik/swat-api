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
% layout 'default';
% title 'Welcome';
<h1>Welcome to the Mojolicious real-time web framework!</h1>
To learn more, you can browse through the documentation
<%= link_to 'here' => '/perldoc' %>.

@@ layouts/default.html.ep
<!DOCTYPE html>
<html>
  <head><title><%= title %></title></head>
  <body><%= content %></body>
</html>
