package swatapi;
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

list of local packages

=item *

install/update/remove site package

=item *

run swat tests

=back

=head2 RESTAPI

=over

=item *

run swat test ( local/swat package ) against a given host and return result in required format ( TAP / nagios )

=back

=head1 INSTALL


    perl Makefile.PL
    make
    make test
    make install

=head1 USAGE

    # run swatapi server

    $ swatapi -d


=head1 HOME PAGE

https://github.com/melezhik/swat-api

=head1 COPYRIGHT

Copyright 2015 Alexey Melezhik.

This program is free software; you can redistribute it and/or modify it under the same terms as Perl itself.


=head1 AUTHOR

Alexey Melezhik

