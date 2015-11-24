#!/usr/bin/env perl

use strict;

use Mojolicious::Lite;

plugin 'BootstrapHelpers';

get '/' => 'home_page';

get '/showcase' => 'showcase_page';

get '/doc' => 'doc_page';

app->start;

