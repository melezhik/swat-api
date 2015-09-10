use inc::Module::Install;

# Define metadata
name           'swatman';
all_from       'lib/swatman.pm';
abstract       'UI and REST api to swat engine';

requires       'swat';

requires       'Mojolicious';
requires       'MetaCPAN::Client';
requires       'Mojolicious::Plugin::BootstrapHelpers';

test_requires  'Test::More'   => '0';

license 'perl';

WriteAll;

