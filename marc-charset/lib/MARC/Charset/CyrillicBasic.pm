package MARC::Charset::CyrillicBasic;

=head1 NAME

MARC::Charset::CyrillicBasic - MARC8/UTF8 encodings for Basic Cyrillic.

=head1 SYNOPSIS

 use MARC::Charset::CyrillicBasic;
 my $cs = MARC::Charset::CyrillicBasic->new();

=head1 DESCRIPTION

MARC::Charset::ASCII provides a mapping between the MARC8 basic Cyrillic 
character set and Unicode(UTF8). It is typically used by MARC::Charset, so 
you probably don't need to use this yourself. 

=head1 METHODS

=cut 

use strict;
use constant CHAR_SIZE	    => 1;
my %marc2unicode;

=head1 

The constructor, which will return you a MARC::Charset::CyrillicBasic object.

=cut

sub new {
    my $class = shift;
    return bless {}, ref($class) || $class;
}

=head1 name()

Returns the name of the character set.

=cut


sub name {
    return('Cyrillic-Basic');
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
    return(undef); ## aren't any
}

=head1 getCharSize()

Returns the number of bytes in each character of this character set.

=cut


sub getCharSize {
    return(CHAR_SIZE);
}

%marc2unicode = (

chr(0x21)=>chr(0x0021), #EXCLAMATION MARK
chr(0x22)=>chr(0x0022), #QUOTATION MARK
chr(0x23)=>chr(0x0023), #NUMBER SIGN
chr(0x24)=>chr(0x0024), #DOLLAR SIGN
chr(0x25)=>chr(0x0025), #PERCENT SIGN
chr(0x26)=>chr(0x0026), #AMPERSAND
chr(0x27)=>chr(0x0027), #APOSTROPHE
chr(0x28)=>chr(0x0028), #OPENING PARENTHESIS / LEFT PARENTHESIS
chr(0x29)=>chr(0x0029), #CLOSING PARENTHESIS / RIGHT PARENTHESIS
chr(0x2A)=>chr(0x002A), #ASTERISK
chr(0x2B)=>chr(0x002B), #PLUS SIGN
chr(0x2C)=>chr(0x002C), #COMMA
chr(0x2D)=>chr(0x002D), #HYPHEN-MINUS
chr(0x2E)=>chr(0x002E), #PERIOD, DECIMAL POINT / FULL STOP
chr(0x2F)=>chr(0x002F), #SLASH / SOLIDUS
chr(0x30)=>chr(0x0030), #DIGIT ZERO
chr(0x31)=>chr(0x0031), #DIGIT ONE
chr(0x32)=>chr(0x0032), #DIGIT TWO
chr(0x33)=>chr(0x0033), #DIGIT THREE
chr(0x34)=>chr(0x0034), #DIGIT FOUR
chr(0x35)=>chr(0x0035), #DIGIT FIVE
chr(0x36)=>chr(0x0036), #DIGIT SIX
chr(0x37)=>chr(0x0037), #DIGIT SEVEN
chr(0x38)=>chr(0x0038), #DIGIT EIGHT
chr(0x39)=>chr(0x0039), #DIGIT NINE
chr(0x3A)=>chr(0x003A), #COLON
chr(0x3B)=>chr(0x003B), #SEMICOLON
chr(0x3C)=>chr(0x003C), #LESS-THAN SIGN
chr(0x3D)=>chr(0x003D), #EQUALS SIGN
chr(0x3E)=>chr(0x003E), #GREATER-THAN SIGN
chr(0x3F)=>chr(0x003F), #QUESTION MARK
chr(0x40)=>chr(0x044E), #LOWERCASE IU / CYRILLIC SMALL LETTER YU
chr(0x41)=>chr(0x0430), #CYRILLIC SMALL LETTER A
chr(0x42)=>chr(0x0431), #CYRILLIC SMALL LETTER BE
chr(0x43)=>chr(0x0446), #CYRILLIC SMALL LETTER TSE
chr(0x44)=>chr(0x0434), #CYRILLIC SMALL LETTER DE
chr(0x45)=>chr(0x0435), #CYRILLIC SMALL LETTER IE
chr(0x46)=>chr(0x0444), #CYRILLIC SMALL LETTER EF
chr(0x47)=>chr(0x0433), #LOWERCASE GE / CYRILLIC SMALL LETTER GHE
chr(0x48)=>chr(0x0445), #LOWERCASE KHA / CYRILLIC SMALL LETTER HA
chr(0x49)=>chr(0x0438), #LOWERCASE II / CYRILLIC SMALL LETTER I
chr(0x4A)=>chr(0x0439), #LOWERCASE SHORT II / CYRILLIC SMALL LETTER SHORT I
chr(0x4B)=>chr(0x043A), #CYRILLIC SMALL LETTER KA
chr(0x4C)=>chr(0x043B), #CYRILLIC SMALL LETTER EL
chr(0x4D)=>chr(0x043C), #CYRILLIC SMALL LETTER EM
chr(0x4E)=>chr(0x043D), #CYRILLIC SMALL LETTER EN
chr(0x4F)=>chr(0x043E), #CYRILLIC SMALL LETTER O
chr(0x50)=>chr(0x043F), #CYRILLIC SMALL LETTER PE
chr(0x51)=>chr(0x044F), #LOWERCASE IA / CYRILLIC SMALL LETTER YA
chr(0x52)=>chr(0x0440), #CYRILLIC SMALL LETTER ER
chr(0x53)=>chr(0x0441), #CYRILLIC SMALL LETTER ES
chr(0x54)=>chr(0x0442), #CYRILLIC SMALL LETTER TE
chr(0x55)=>chr(0x0443), #CYRILLIC SMALL LETTER U
chr(0x56)=>chr(0x0436), #CYRILLIC SMALL LETTER ZHE
chr(0x57)=>chr(0x0432), #CYRILLIC SMALL LETTER VE
chr(0x58)=>chr(0x044C), #CYRILLIC SMALL LETTER SOFT SIGN
chr(0x59)=>chr(0x044B), #LOWERCASE YERI / CYRILLIC SMALL LETTER YERI
chr(0x5A)=>chr(0x0437), #CYRILLIC SMALL LETTER ZE
chr(0x5B)=>chr(0x0448), #CYRILLIC SMALL LETTER SHA
chr(0x5C)=>chr(0x044D), #LOWERCASE REVERSED E / CYRILLIC SMALL LETTER E
chr(0x5D)=>chr(0x0449), #CYRILLIC SMALL LETTER SHCHA
chr(0x5E)=>chr(0x0447), #CYRILLIC SMALL LETTER CHE
chr(0x5F)=>chr(0x044A), #CYRILLIC SMALL LETTER HARD SIGN
chr(0x60)=>chr(0x042E), #UPPERCASE IU / CYRILLIC CAPITAL LETTER YU
chr(0x61)=>chr(0x0410), #CYRILLIC CAPITAL LETTER A
chr(0x62)=>chr(0x0411), #CYRILLIC CAPITAL LETTER BE
chr(0x63)=>chr(0x0426), #CYRILLIC CAPITAL LETTER TSE
chr(0x64)=>chr(0x0414), #CYRILLIC CAPITAL LETTER DE
chr(0x65)=>chr(0x0415), #CYRILLIC CAPITAL LETTER IE
chr(0x66)=>chr(0x0424), #CYRILLIC CAPITAL LETTER EF
chr(0x67)=>chr(0x0413), #UPPERCASE GE / CYRILLIC CAPITAL LETTER GHE
chr(0x68)=>chr(0x0425), #UPPERCASE KHA / CYRILLIC CAPITAL LETTER HA
chr(0x69)=>chr(0x0418), #UPPERCASE II / CYRILLIC CAPITAL LETTER I
chr(0x6A)=>chr(0x0419), #UPPERCASE SHORT II / CYRILLIC CAPITAL LETTER SHORT I
chr(0x6B)=>chr(0x041A), #CYRILLIC CAPITAL LETTER KA
chr(0x6C)=>chr(0x041B), #CYRILLIC CAPITAL LETTER EL
chr(0x6D)=>chr(0x041C), #CYRILLIC CAPITAL LETTER EM
chr(0x6E)=>chr(0x041D), #CYRILLIC CAPITAL LETTER EN
chr(0x6F)=>chr(0x041E), #CYRILLIC CAPITAL LETTER O
chr(0x70)=>chr(0x041F), #CYRILLIC CAPITAL LETTER PE
chr(0x71)=>chr(0x042F), #UPPERCASE IA / CYRILLIC CAPITAL LETTER YA
chr(0x72)=>chr(0x0420), #CYRILLIC CAPITAL LETTER ER
chr(0x73)=>chr(0x0421), #CYRILLIC CAPITAL LETTER ES
chr(0x74)=>chr(0x0422), #CYRILLIC CAPITAL LETTER TE
chr(0x75)=>chr(0x0423), #CYRILLIC CAPITAL LETTER U
chr(0x76)=>chr(0x0416), #CYRILLIC CAPITAL LETTER ZHE
chr(0x77)=>chr(0x0412), #CYRILLIC CAPITAL LETTER VE
chr(0x78)=>chr(0x042C), #CYRILLIC CAPITAL LETTER SOFT SIGN
chr(0x79)=>chr(0x042B), #UPPERCASE YERI / CYRILLIC CAPITAL LETTER YERI
chr(0x7A)=>chr(0x0417), #CYRILLIC CAPITAL LETTER ZE
chr(0x7B)=>chr(0x0428), #CYRILLIC CAPITAL LETTER SHA
chr(0x7C)=>chr(0x042D), #CYRILLIC CAPITAL LETTER E
chr(0x7D)=>chr(0x0429), #CYRILLIC CAPITAL LETTER SHCHA
chr(0x7E)=>chr(0x0427), #CYRILLIC CAPITAL LETTER CHE

);

=head1 TODO

=over 4 

=item *

=back

=head1 AUTHORS

=over 4

=item Ed Summers <ehs@pobox.com>

=back

=cut



1;
