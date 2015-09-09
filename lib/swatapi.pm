package swatapi;
our $VERSION = '0.1.0';
1;


__END__


=head1 SYNOPSIS

UI and REST api to L<swat|https://github.com/melezhik/swat> engine.

=head1 Features List

    ## UI
    - list of available /installed site swat packages
    - list of local swat packages ( projects )
    - install/update/remove site package
    - show curl call to run swat test for given local/site package
    - run test manually

    ## RESTAPI
    - run swat test ( local/site package ) against a given host and return result in required format:
        - TAP
        - nagios
        - sensu

=head1 INSTALL


    perl Makefile.PL
    make
    make test
    make install

=head1 USAGE

    # run swatapi server

    $ swatapi -d


=head1 HOME PAGE

https://github.com/melezhik/swatapi


=head1 COPYRIGHT

Copyright 2015 Alexey Melezhik.

This program is free software; you can redistribute it and/or modify it under the same terms as Perl itself.


=head1 AUTHOR

Alexey Melezhik

