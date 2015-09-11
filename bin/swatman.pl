#!/usr/bin/env perl

use strict;
use Mojolicious::Lite;

use Data::Dumper;
require CPAN;

plugin 'BootstrapHelpers';

get '/' => 'search_form';

get '/search' => sub {

    my $c = shift;

    my $sq = $c->param('search_query');

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
    
                my $cpan_obj = CPAN::Shell->expand( "Module", $pkg ) or die $!;
            
                app->log->debug($cpan_obj->as_string);

                my $author = CPAN::Shell->expand( 'Author', $cpan_obj->userid );

                push @list, {
                    name => $pkg ,
                    version => $cpan_obj->cpan_version ,
                    author => ($author->fullname).' / '.($author->email),
                    abstract => "",
                    description => $cpan_obj->description,
                    date => $cpan_obj->distribution->upload_date,
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
            }else{
                app->log->debug("$pkg successfuly found on cpanmeta");
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
            <th>date</th>
            <th>author</th>
            <th>version</th>
            <th>description</th>
        </tr>
    </thead>
    <tbody>
    <% foreach my $p (@{$list}) { %>
    <tr>
        <td> <%= $p->{name}  %></td>
        <td> <%= $p->{date}  %></td>
        <td> <%= $p->{author}  %></td>
        <td> <%= $p->{version} %></td>
        <td> <%= $p->{description} %></td>
    </tr>
    <% } %>
    <tbody>
    </table>
    <% } %>

<!--
    Debug Info
    Packages found:<%= $count  %>
-->
