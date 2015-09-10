package swatman;
our $VERSION = '0.1.0';
1;


__END__


=head1 SYNOPSIS

UI and REST api to L<swat|https://github.com/melezhik/swat> engine.

=head1 Features List

=head2 UI

=over 

=item *

list of available / installed swat packages

=item *

install/update/remove swat package

=back

=head2 RESTAPI

=over

=item *

run swat tests against a given host and return result in required format ( TAP / nagios )

=back

=head1 INSTALL


    perl Makefile.PL
    make
    make test
    make install

=head1 USAGE

    # run swatman server

    $ swatman -d


=head1 HOME PAGE

https://github.com/melezhik/swatman

=head1 COPYRIGHT

Copyright 2015 Alexey Melezhik.

This program is free software; you can redistribute it and/or modify it under the same terms as Perl itself.


=head1 AUTHOR

Alexey Melezhik

