package MARC::File;

=head1 NAME

MARC::File - Base class for files of MARC records

=cut

use 5.6.0;
use strict;
use integer;
use vars qw( $VERSION $ERROR );

=head1 VERSION

Version 0.90

    $Id: File.pm,v 1.2 2002/04/01 20:34:24 petdance Exp $

=cut

our $VERSION = '0.90';

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

=head2 in()

Opens a file for input.

=cut

sub in {
    my $class = shift;
    my $filename = shift;

    my $self = {
	filename => $filename,
    };

    bless $self, $class;

    if ( !open( $self->{fh}, "<", $filename ) ) {
	undef $self;
	$MARC::File::ERROR = "Couldn't open $filename: $!";
    }

    return $self;
} # new()

sub out {
    die "Not yet written";
}

sub close {
    my $self = shift;

    close( $self->{fh} );
    delete $self->{fh};

    return;
}

sub _unimplemented() {
    my $self = shift;
    my $method = shift;

    warn "Method $method must be overridden";
}

sub next { $_[0]->_unimplemented("next"); }
sub skip { $_[0]->_unimplemented("skip"); }
sub write { $_[0]->_unimplemented("write"); }

# NOTE: _gripe can be called as an object method, or not.  Your choice.
sub _gripe(@) {
    if ( @_ ) {
	shift if ref($_[0]) =~ /^MARC::File/;	# Skip first parm if it's a $self
	$ERROR = join( "", @_ );
    }

    return undef;
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

