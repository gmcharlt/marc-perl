package MARC::Charset::Generic;

use strict;
use base qw( Exporter );

=head1 NAME

MARC::Charset::Generic - Superclass for Charset Classes 

=head1 SYNOPSIS

    There is no need to use this class directly. 

=head1 DESCRIPTION

All of the MARC::Charset::* classes inherit from MARC::Charset::Generic, 
so that they all implement some core methods. There is no constructor 
method for MARC::Charset::Generic since it is only meant to be subclassed,
not instantiated.

=head1 EXPORTS

These constants can be exported with the :all tag. They are constants defined
by the Library of Congress for indentifying and switching to alternate 
character sets.

    use MARC::Charset::Generic qw( :all );

=cut

use constant ESCAPE		=> chr(0x1B);
use constant SINGLE_G0_A	=> chr(0x28);
use constant SINGLE_G0_B	=> chr(0x2C);
use constant MULTI_G0_A		=> chr(0x24);
use constant MULTI_G0_B		=> chr(0x24) . chr(0x2C);

use constant SINGLE_G1_A	=> chr(0x29);
use constant SINGLE_G1_B	=> chr(0x2D);
use constant MULTI_G1_A		=> chr(0x24) . chr(0x29);
use constant MULTI_G1_B		=> chr(0x24) . chr(0x2D);

use constant GREEK_SYMBOLS	=> chr(0x67);
use constant SUBSCRIPTS		=> chr(0x62);
use constant SUPERSCRIPTS	=> chr(0x70);
use constant ASCII_DEFAULT	=> chr(0x73);

use constant BASIC_ARABIC	=> chr(0x33);
use constant EXTENDED_ARABIC	=> chr(0x34);
use constant BASIC_LATIN	=> chr(0x42);
use constant EXTENDED_LATIN	=> chr(0x45);
use constant CJK		=> chr(0x31);
use constant BASIC_CYRILLIC	=> chr(0x4E);
use constant EXTENDED_CYRILLIC	=> chr(0x51);
use constant BASIC_GREEK	=> chr(0x53);
use constant BASIC_HEBREW	=> chr(0x32);

our %EXPORT_TAGS = ( all => 
	[ qw( 
	ESCAPE  GREEK_SYMBOLS  SUBSCRIPTS  SUPERSCRIPTS  ASCII_DEFAULT 
	SINGLE_G0_A  SINGLE_G0_B  MULTI_G0_A  MULTI_G0_B  SINGLE_G1_A 
	SINGLE_G1_B  MULTI_G1_A  MULTI_G1_B  BASIC_ARABIC  
	EXTENDED_ARABIC  BASIC_LATIN  EXTENDED_LATIN CJK  BASIC_CYRILLIC  
	EXTENDED_CYRILLIC BASIC_GREEK BASIC_HEBREW
	) ]
    );

our @EXPORT_OK = qw(
	ESCAPE  GREEK_SYMBOLS  SUBSCRIPTS  SUPERSCRIPTS  ASCII_DEFAULT 
	SINGLE_G0_A  SINGLE_G0_B  MULTI_G0_A  MULTI_G0_B  SINGLE_G1_A 
	SINGLE_G1_B  MULTI_G1_A  MULTI_G1_B  BASIC_ARABIC  
	EXTENDED_ARABIC  BASIC_LATIN  EXTENDED_LATIN CJK  BASIC_CYRILLIC  
	EXTENDED_CYRILLIC BASIC_GREEK BASIC_HEBREW
    );

=head1 METHODS

=head2 name()

Returns the name of the character set.

=cut

sub name {
    my $self = shift;
    return( $self->{ NAME } );
}

=head2 getCharsetCode()

Returns the character set code for this character set, as defined by the 
Library of Congress.

=cut 

sub getCharsetCode {
    my $self = shift;
    return( $self->{ CHARSETCODE } );
}

=head2 getCharSize()

Returns the number of bytes in each character of this character set.

=cut

sub getCharSize {
    my $self = shift;
    return( $self->{ CHARSIZE } );
}

=head1 TODO

=over 4 

=item * Nothing

=back

=head1 AUTHORS

=over 4

=item Ed Summers <ehs@pobox.com>

=back

=cut

1;
