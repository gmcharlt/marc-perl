package MARC::File::USMARC;

=head1 NAME

MARC::File::USMARC - USMARC-specific file handling

=cut

use 5.6.0;
use strict;
use integer;
use vars qw( $VERSION $ERROR );

=head1 VERSION

Version 0.90

    $Id: USMARC.pm,v 1.1 2002/04/01 17:18:28 petdance Exp $

=cut

our $VERSION = '0.90';

use MARC::File;
our @ISA = qw( MARC::File );

=head1 SYNOPSIS

    use MARC::File::USMARC;

    my $file = MARC::File::USMARC::in( $filename );
    
    while ( my $marc = $file->next() ) {
	# Do something
    }
    $file->close();
    undef $file;

=head1 EXPORT

None.  

=head1 METHODS

=head2 next()

Reads the next record from the file handle passed in.

=cut

sub next {
    my $self = shift;

    my $usmarc = $self->_next();

    return $usmarc ? MARC::Record->new_from_usmarc($usmarc) : undef;
}

sub _next {
    my $self = shift;

    my $fh = $self->{fh};

    my $reclen;

    read( $fh, $reclen, 5 )
	or return _gripe( "Error reading record length: $!" );

    $reclen =~ /^\d{5}$/
	or return _gripe( "Invalid record length \"$reclen\"" );
    my $usmarc = $reclen;
    read( $fh, substr($usmarc,5), $reclen-5 )
	or return _gripe( "Error reading $reclen byte record: $!" );

    return $usmarc;
}

1;

__END__

=head1 RELATED MODULES

L<MARC::Record>

=head1 TODO

Make some sort of autodispatch so that you don't have to explicitly
specify the MARC::File::X subclass, sort of like how DBI knows to
use DBD::Oracle or DBD::Mysql.

=head1 LICENSE

This code may be distributed under the same terms as Perl itself. 

Please note that these modules are not products of or supported by the
employers of the various contributors to the code.

=head1 AUTHOR

Andy Lester, E<lt>marc@petdance.comE<gt> or E<lt>alester@flr.follett.comE<gt>

=cut

