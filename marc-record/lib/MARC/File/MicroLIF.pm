package MARC::File::MicroLIF;

=head1 NAME

MARC::File::MicroLIF - MicroLIF-specific file handling

=cut

use 5.6.0;
use strict;
use integer;
use vars qw( $VERSION $ERROR );

=head1 VERSION

Version 0.90

    $Id: MicroLIF.pm,v 1.3 2002/04/01 22:19:05 petdance Exp $

=cut

our $VERSION = '0.90';

use MARC::File;
our @ISA = qw( MARC::File );

use MARC::Record;

=head1 SYNOPSIS

    use MARC::File::MicroLIF;

    my $file = MARC::File::MicroLIF::in( $filename );
    
    while ( my $marc = $file->next() ) {
	# Do something
    }
    $file->close();
    undef $file;

=head1 EXPORT

None.  

=head1 METHODS


sub _next {
    my $self = shift;

    my $fh = $self->{fh};

    my $reclen;

    read( $fh, $reclen, 5 )
	or return $self->_gripe( "Error reading record length: $!" );

    $reclen =~ /^\d{5}$/
	or return $self->_gripe( "Invalid record length \"$reclen\"" );
    my $usmarc = $reclen;
    read( $fh, substr($usmarc,5), $reclen-5 )
	or return $self->_gripe( "Error reading $reclen byte record: $!" );

    return $usmarc;
}

=head2 skip

Skips over the next record in the file.  Same as C<next()>,
without the overhead of parsing a record you're going to throw away
anyway.

Returns 1 or undef.

=cut

sub skip {
    my $fh = shift;

    my $usmarc = $self->_next();

    return $usmarc ? 1 : undef;
}

=head2 new_from_microlif()

Constructor for handling data from a microlif file.  This function takes care of all
the directory parsing & mangling.

Any warnings or coercions can be checked in the C<warnings()> function.

Note that we are NOT expecting to get the trailing "`" mark at the end of the last line.

=cut

sub new_from_microlif($) {
	my $class = shift;
	my $text = shift;
	my $self = new($class);

	my @lines = split( /\n/, $text );
	for my $line ( @lines ) {
		# Ignore the file header if the calling program hasn't already dealt with it
		next if $line =~ /^HDR/;

		($line =~ s/^(\d\d\d|LDR)//) or
			return _gripe( "Invalid tag number: ", substr( $line, 0, 3 ) );
		my $tagno = $1;

		($line =~ s/\^$//) or
			$self->_warn( "Tag $tagno is missing a trailing caret." );

		if ( $tagno eq "LDR" ) {
			$self->leader( substr( $line, 0, LEADER_LEN ) );
		} elsif ( $tagno < 10 ) {
			$self->add_fields( $tagno, $line );
		} else {
			$line =~ s/^(.)(.)//;
			my ($ind1,$ind2) = ($1,$2);
			my @subfields;
			my @subfield_data_pairs = split( /_(?=[a-z0-9])/, $line );
			shift @subfield_data_pairs; # Leading _ makes an empty pair
			for my $pair ( @subfield_data_pairs ) {
				my ($subfield,$data) = (substr( $pair, 0, 1 ), substr( $pair, 1 ));
				push( @subfields, $subfield, $data );
			}
			$self->add_fields( $tagno, $ind1, $ind2, @subfields );
		}
	} # for

	return $self;
}

1;

__END__

=head1 RELATED MODULES

L<MARC::File>

=head1 LICENSE

This code may be distributed under the same terms as Perl itself. 

Please note that these modules are not products of or supported by the
employers of the various contributors to the code.

=head1 AUTHOR

Andy Lester, E<lt>marc@petdance.comE<gt> or E<lt>alester@flr.follett.comE<gt>

=cut

