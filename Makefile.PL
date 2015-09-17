use inc::Module::Install;

# Define metadata
name           'swatman';
all_from       'lib/swatman.pm';
abstract       'UI and REST api to swat engine';

requires       'swat';

requires       'Mojolicious';
requires       'Mojo::Date'; 
requires       'MetaCPAN::Client';
requires       'Mojolicious::Plugin::BootstrapHelpers';
requires       'CHI'; 
requires       'Time::Piece';
 
test_requires  'Test::More'   => '0';

license 'perl';

WriteAll;

