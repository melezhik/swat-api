use inc::Module::Install;

# Define metadata
name           'swatapi';
all_from       'lib/swatapi.pm';
abstract       'UI and REST api to swat engine';

requires       'swat';

requires       'Mojolicious';
requires       'MetaCPAN::Client';

test_requires  'Test::More'   => '0';

license 'perl';

WriteAll;

