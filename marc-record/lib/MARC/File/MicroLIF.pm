package MARC::File::MicroLIF;

=head1 NAME

MARC::File::MicroLIF - MicroLIF-specific file handling

=cut

use strict;
use integer;
eval 'use warnings' if $] >= 5.006;

use vars qw( $ERROR );

=head1 VERSION

Version 1.13

    $Id: MicroLIF.pm,v 1.20 2002/11/27 16:39:15 edsummers Exp $

=cut

use vars '$VERSION'; $VERSION = '1.14';

use MARC::File;
use vars qw( @ISA ); @ISA = qw( MARC::File );

use MARC::Record qw( LEADER_LEN );

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

=cut

sub _next {
    my $self = shift;

    my $fh = $self->{fh};

    local $/ = "`\n";
    
    my $lifrec = <$fh>;

    return $lifrec;
}

sub decode {
    my $self = shift;
    my $location = '';
    my $text = '';

    ## decode can be called as a MARC::File::* object method, or as a function
    ## we need to handle our parms slightly different in each case, and 
    ## (if appropriate) capture the record number for warnings messages.
    if ( $self =~ /^MARC::File/ ) {
	$location = 'in record '.$self->{recnum};
	$text = shift;
    } else {
	$location = 'in record 1';
	$text = $self;
    }

    my $marc = MARC::Record->new();

    my @lines = split( /\n/, $text );
    for my $line ( @lines ) {
	# Ignore the file header if the calling program hasn't already dealt with it
	next if $line =~ /^HDR/;

	($line =~ s/^([0-9A-Za-z]{3})//) or
	    $marc->_warn( "Invalid tag number: ".substr( $line, 0, 3 )." $location" );
	my $tagno = $1;

	($line =~ s/\^`?$//) 
	    or $marc->_warn( "Tag $tagno $location is missing a trailing caret." );

	if ( $tagno eq "LDR" ) {
	    $marc->leader( substr( $line, 0, LEADER_LEN ) );
	} elsif ( $tagno =~ /^\d+$/ and $tagno < 10 ) {
	    $marc->add_fields( $tagno, $line );
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
	    $marc->add_fields( $tagno, $ind1, $ind2, @subfields );
	}
    } # for

    return $marc;
}

1;

__END__

=head1 TODO

=over 4

=back

=head1 RELATED MODULES

L<MARC::File>

=head1 LICENSE

This code may be distributed under the same terms as Perl itself. 

Please note that these modules are not products of or supported by the
employers of the various contributors to the code.

=head1 AUTHOR

Andy Lester, E<lt>marc@petdance.comE<gt> or E<lt>alester@flr.follett.comE<gt>

=cut

