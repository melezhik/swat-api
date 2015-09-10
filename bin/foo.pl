# simple usage
#use MetaCPAN::Client;
#use Data::Dumper;

#use strict;


#my $mcpan  = MetaCPAN::Client->new();
#my $list = $mcpan->module(  { name => 'swat' } );

#print Dumper($list->items);


# examples/module.pl

use strict;
use warnings;
use DDP;

use MetaCPAN::Client;

my $data = MetaCPAN::Client->new->module({ name => '' });

my $list = $data->items;
for my $module (@{$list}){
    my %output = (
        NAME        => $module->name,
        ABSTRACT    => $module->abstract,
        DESCRIPTION => $module->description,
        RELEASE     => $module->release,
        AUTHOR      => $module->author,
        VERSION     => $module->version,
    );
    p %output;
}
