package MARC::Charset::ASCII;

use MARC::Charset::Generic qw( :all );
use base qw( MARC::Charset::Generic );

=head1 NAME

MARC::Charset::ASCII - MARC8/UTF8 mappings for ASCII

=head1 SYNOPSIS

 use MARC::Charset::ASCII;
 my $c = MARC::Charset::ASCII->new();

=head1 DESCRIPTION

MARC::Charset::ASCII provides a mapping between the MARC8 ASCII character
set and Unicode(UTF8). It is typically used by MARC::Charset, so you 
probably don't need to use this yourself. It inherits from
MARC::Charset::Generic so you'll have to look at those docs to see 
all the methods you can call.

=head1 METHODS

=cut 

use strict;
our %marc2unicode;

=head1 

The constructor, which will return you a MARC::Charset::ASCII object.

=cut

sub new {
    my $class = shift;
    return bless 
	{ 
	    NAME	=> 'ASCII',
	    CHARSETCODE => ASCII_DEFAULT, 
	    CHARSIZE	=> 1 
	} , ref($class) || $class;
}

=head1 lookup()

The workhorse method that does the lookup. Pass it an a character and you'll
get back the UTF8 character.

=cut

sub lookup {
    my ($self,$char) = @_; 
    return($marc2unicode{$char});
}

=head1 combining()

Pass it a character and you'll get back a true value (1) if the character is 
a combining character, and false (undef) if it is not.

=cut

sub combining {
    return(undef); ## no combining ASCII characters
}

%marc2unicode = (

chr(0x20)=>chr(0x0020), # SPACE, BLANK / SPACE
chr(0x21)=>chr(0x0021), # EXCLAMATION MARK
chr(0x22)=>chr(0x0022), # QUOTATION MARK
chr(0x23)=>chr(0x0023), # NUMBER SIGN
chr(0x24)=>chr(0x0024), # DOLLAR SIGN
chr(0x25)=>chr(0x0025), # PERCENT SIGN
chr(0x26)=>chr(0x0026), # AMPERSAND
chr(0x27)=>chr(0x0027), # APOSTROPHE
chr(0x28)=>chr(0x0028), # OPENING PARENTHESIS / LEFT PARENTHESIS
chr(0x29)=>chr(0x0029), # CLOSING PARENTHESIS / CLOSING PARENTHESIS
chr(0x2A)=>chr(0x002A), # ASTERISK
chr(0x2B)=>chr(0x002B), # PLUS SIGN
chr(0x2C)=>chr(0x002C), # COMMA
chr(0x2D)=>chr(0x002D), # HYPHEN-MINUS
chr(0x2E)=>chr(0x002E), # PERIOD, DECIMAL POINT / FULL STOP
chr(0x2F)=>chr(0x002F), # SLASH / SOLIDUS
chr(0x30)=>chr(0x0030), # DIGIT ZERO
chr(0x31)=>chr(0x0031), # DIGIT ONE
chr(0x32)=>chr(0x0032), # DIGIT TWO
chr(0x33)=>chr(0x0033), # DIGIT THREE
chr(0x34)=>chr(0x0034), # DIGIT FOUR
chr(0x35)=>chr(0x0035), # DIGIT FIVE
chr(0x36)=>chr(0x0036), # DIGIT SIX
chr(0x37)=>chr(0x0037), # DIGIT SEVEN
chr(0x38)=>chr(0x0038), # DIGIT EIGHT
chr(0x39)=>chr(0x0039), # DIGIT NINE
chr(0x3A)=>chr(0x003A), # COLON
chr(0x3B)=>chr(0x003B), # SEMICOLON
chr(0x3C)=>chr(0x003C), # LESS-THAN SIGN
chr(0x3D)=>chr(0x003D), # EQUALS SIGN
chr(0x3E)=>chr(0x003E), # GREATER-THAN SIGN
chr(0x3F)=>chr(0x003F), # QUESTION MARK
chr(0x40)=>chr(0x0040), # COMMERCIAL AT
chr(0x41)=>chr(0x0041), # LATIN CAPITAL LETTER A
chr(0x42)=>chr(0x0042), # LATIN CAPITAL LETTER B
chr(0x43)=>chr(0x0043), # LATIN CAPITAL LETTER C
chr(0x44)=>chr(0x0044), # LATIN CAPITAL LETTER D
chr(0x45)=>chr(0x0045), # LATIN CAPITAL LETTER E
chr(0x46)=>chr(0x0046), # LATIN CAPITAL LETTER F
chr(0x47)=>chr(0x0047), # LATIN CAPITAL LETTER G
chr(0x48)=>chr(0x0048), # LATIN CAPITAL LETTER H
chr(0x49)=>chr(0x0049), # LATIN CAPITAL LETTER I
chr(0x4A)=>chr(0x004A), # LATIN CAPITAL LETTER J
chr(0x4B)=>chr(0x004B), # LATIN CAPITAL LETTER K
chr(0x4C)=>chr(0x004C), # LATIN CAPITAL LETTER L
chr(0x4D)=>chr(0x004D), # LATIN CAPITAL LETTER M
chr(0x4E)=>chr(0x004E), # LATIN CAPITAL LETTER N
chr(0x4F)=>chr(0x004F), # LATIN CAPITAL LETTER O
chr(0x50)=>chr(0x0050), # LATIN CAPITAL LETTER P
chr(0x51)=>chr(0x0051), # LATIN CAPITAL LETTER Q
chr(0x52)=>chr(0x0052), # LATIN CAPITAL LETTER R
chr(0x53)=>chr(0x0053), # LATIN CAPITAL LETTER S
chr(0x54)=>chr(0x0054), # LATIN CAPITAL LETTER T
chr(0x55)=>chr(0x0055), # LATIN CAPITAL LETTER U
chr(0x56)=>chr(0x0056), # LATIN CAPITAL LETTER V
chr(0x57)=>chr(0x0057), # LATIN CAPITAL LETTER W
chr(0x58)=>chr(0x0058), # LATIN CAPITAL LETTER X
chr(0x59)=>chr(0x0059), # LATIN CAPITAL LETTER Y
chr(0x5A)=>chr(0x005A), # LATIN CAPITAL LETTER Z
chr(0x5B)=>chr(0x005B), # OPENING SQUARE BRACKET / LEFT SQUARE BRACKET
chr(0x5C)=>chr(0x005C), # REVERSE SLASH / REVERSE SOLIDUS
chr(0x5D)=>chr(0x005D), # CLOSING SQUARE BRACKET / RIGHT SQUARE BRACKET
chr(0x5E)=>chr(0x005E), # SPACING CIRCUMFLEX / CIRCUMFLEX ACCENT
chr(0x5F)=>chr(0x005F), # SPACING UNDERSCORE / LOW LINE
chr(0x60)=>chr(0x0060), # SPACING GRAVE / GRAVE ACCENT
chr(0x61)=>chr(0x0061), # LATIN SMALL LETTER A
chr(0x62)=>chr(0x0062), # LATIN SMALL LETTER B
chr(0x63)=>chr(0x0063), # LATIN SMALL LETTER C
chr(0x64)=>chr(0x0064), # LATIN SMALL LETTER D
chr(0x65)=>chr(0x0065), # LATIN SMALL LETTER E
chr(0x66)=>chr(0x0066), # LATIN SMALL LETTER F
chr(0x67)=>chr(0x0067), # LATIN SMALL LETTER G
chr(0x68)=>chr(0x0068), # LATIN SMALL LETTER H
chr(0x69)=>chr(0x0069), # LATIN SMALL LETTER I
chr(0x6A)=>chr(0x006A), # LATIN SMALL LETTER J
chr(0x6B)=>chr(0x006B), # LATIN SMALL LETTER K
chr(0x6C)=>chr(0x006C), # LATIN SMALL LETTER L
chr(0x6D)=>chr(0x006D), # LATIN SMALL LETTER M
chr(0x6E)=>chr(0x006E), # LATIN SMALL LETTER N
chr(0x6F)=>chr(0x006F), # LATIN SMALL LETTER O
chr(0x70)=>chr(0x0070), # LATIN SMALL LETTER P
chr(0x71)=>chr(0x0071), # LATIN SMALL LETTER Q
chr(0x72)=>chr(0x0072), # LATIN SMALL LETTER R
chr(0x73)=>chr(0x0073), # LATIN SMALL LETTER S
chr(0x74)=>chr(0x0074), # LATIN SMALL LETTER T
chr(0x75)=>chr(0x0075), # LATIN SMALL LETTER U
chr(0x76)=>chr(0x0076), # LATIN SMALL LETTER V
chr(0x77)=>chr(0x0077), # LATIN SMALL LETTER W
chr(0x78)=>chr(0x0078), # LATIN SMALL LETTER X
chr(0x79)=>chr(0x0079), # LATIN SMALL LETTER Y
chr(0x7A)=>chr(0x007A), # LATIN SMALL LETTER Z
chr(0x7B)=>chr(0x007B), # OPENING CURLY BRACKET / LEFT CURLY BRACKET
chr(0x7C)=>chr(0x007C), # VERTICAL BAR (FILL) / VERTICAL LINE
chr(0x7D)=>chr(0x007D), # CLOSING CURLY BRACKET / RIGHT CURLY BRACKET
chr(0x7E)=>chr(0x007E), # SPACING TILDE / TILDE

);

=head1 TODO

=over 4 

=item *

=back

=head1 SEE ALSO

=over 4 

=item MARC::Charset::Generic

=back

=head1 AUTHORS

=over 4

=item Ed Summers <ehs@pobox.com>

=back

=cut

1;
