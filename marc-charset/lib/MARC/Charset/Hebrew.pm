package MARC::Charset::Hebrew;

=head1 NAME

MARC::Charset::Hebrew - MARC8/UTF8 mappings for Hebrew

=head1 SYNOPSIS

 use MARC::Charset::Hebrew;
 my $cs = MARC::Charset::Hebrew->new();

=head1 DESCRIPTION

MARC::Charset::Hebrew provides a mapping between the MARC8 Hebrew character
set and Unicode(UTF8). It is typically used by MARC::Charset, so you 
probably don't need to use this yourself. 

=head1 METHODS

=cut 

use strict;
use constant CHAR_SIZE	    => 1;
my (%marc2unicode,%combining);

=head1 

The constructor, which will return you a MARC::Charset::Hebrew object.

=cut


sub new {
    my $class = shift;
    return bless {}, ref($class) || $class;
}

=head1 name()

Returns the name of the character set.

=cut


sub name {
    return('Hebrew');
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
    return(undef); ## none???
}

=head1 getCharSize()

Returns the number of bytes in each character of this character set.

=cut


sub getCharSize {
    return(CHAR_SIZE);
}


%marc2unicode = (

chr(0x21)=>chr(0x0021), #EXCLAMATION MARK
chr(0x22)=>chr(0x05F4), #QUOTATION MARK, GERSHAYIM / HEB PUNCTUATION GERSHAYIM
chr(0x23)=>chr(0x0023), #NUMBER SIGN
chr(0x24)=>chr(0x0024), #DOLLAR SIGN
chr(0x25)=>chr(0x0025), #PERCENT SIGN
chr(0x26)=>chr(0x0026), #AMPERSAND
chr(0x27)=>chr(0x05F3), #APOSTROPHE, GERESH / HEBREW PUNCTUATION GERESH
chr(0x28)=>chr(0x0028), #OPENING PARENTHESIS / LEFT PARENTHESIS
chr(0x29)=>chr(0x0029), #CLOSING PARENTHESIS / RIGHT PARENTHESIS
chr(0x2A)=>chr(0x002A), #ASTERISK
chr(0x2B)=>chr(0x002B), #PLUS SIGN
chr(0x2C)=>chr(0x002C), #COMMA
chr(0x2D)=>chr(0x05BE), #HYPHEN-MINUS, MAKEF / HEBREW PUNCTUATION MAQAF
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
chr(0x40)=>chr(0x05B7), #HEBREW POINT PATAH
chr(0x41)=>chr(0x05B8), #KAMATS / HEBREW POINT QAMATS
chr(0x42)=>chr(0x05B6), #HEBREW POINT SEGOL
chr(0x43)=>chr(0x05B5), #TSEREH / HEBREW POINT TSERE
chr(0x45)=>chr(0x05B4), #HIRIK / HEBREW POINT HIRIQ
chr(0x45)=>chr(0x05B9), #HOLAM, LEFT SIN DOT / HEBREW POINT HOLAM
chr(0x46)=>chr(0x05BB), #KUBUTS / HEBREW POINT QUBUTS
chr(0x47)=>chr(0x05B0), #HEBREW POINT SHEVA
chr(0x48)=>chr(0x05B2), #HEBREW POINT HATAF PATAH
chr(0x49)=>chr(0x05B3), #HATAF KAMATS / HEBREW POINT HATAF QAMATS
chr(0x4A)=>chr(0x05B1), #HEBREW POINT HATAF SEGOL
chr(0x4B)=>chr(0x05BC), #HEBREW POINT DAGESH OR MAPIQ
chr(0x4C)=>chr(0x05BF), #RAFEH / HEBREW POINT RAFE
chr(0x4D)=>chr(0x05C1), #RIGHT SHIN DOT / HEBREW POINT  SHIN DOT
chr(0x4E)=>chr(0xFB1E), #VARIKA / HEBREW POINT JUDEO-SPANISH VARIKA
chr(0x5B)=>chr(0x005B), #OPENING SQUARE BRACKET / LEFT SQUARE BRACKET
chr(0x5D)=>chr(0x005D), #CLOSING SQUARE BRACKET / RIGHT SQUARE BRACKET
chr(0x60)=>chr(0x05D0), #HEBREW LETTER ALEF
chr(0x61)=>chr(0x05D1), #HEBREW LETTER BET
chr(0x62)=>chr(0x05D2), #HEBREW LETTER GIMEL
chr(0x63)=>chr(0x05D3), #HEBREW LETTER DALET
chr(0x64)=>chr(0x05D4), #HEBREW LETTER HE
chr(0x65)=>chr(0x05D5), #HEBREW LETTER VAV
chr(0x66)=>chr(0x05D6), #HEBREW LETTER ZAYIN
chr(0x67)=>chr(0x05D7), #HEBREW LETTER HET
chr(0x68)=>chr(0x05D8), #HEBREW LETTER TET
chr(0x69)=>chr(0x05D9), #HEBREW LETTER YOD
chr(0x6A)=>chr(0x05DA), #HEBREW LETTER FINAL KAF
chr(0x6B)=>chr(0x05DB), #HEBREW LETTER KAF
chr(0x6C)=>chr(0x05DC), #HEBREW LETTER LAMED
chr(0x6D)=>chr(0x05DD), #HEBREW LETTER FINAL MEM
chr(0x6E)=>chr(0x05DE), #HEBREW LETTER MEM
chr(0x6F)=>chr(0x05DF), #HEBREW LETTER FINAL NUN
chr(0x70)=>chr(0x05E0), #HEBREW LETTER NUN
chr(0x71)=>chr(0x05E1), #HEBREW LETTER SAMEKH
chr(0x72)=>chr(0x05E2), #HEBREW LETTER AYIN
chr(0x73)=>chr(0x05E3), #HEBREW LETTER FINAL PE
chr(0x74)=>chr(0x05E4), #HEBREW LETTER PE
chr(0x75)=>chr(0x05E5), #HEBREW LETTER FINAL TSADI
chr(0x76)=>chr(0x05E6), #HEBREW LETTER TSADI
chr(0x77)=>chr(0x05E7), #HEBREW LETTER QOF / KOF
chr(0x78)=>chr(0x05E8), #HEBREW LETTER RESH
chr(0x79)=>chr(0x05E9), #HEBREW LETTER SHIN
chr(0x7A)=>chr(0x05EA), #HEBREW LETTER TAV
chr(0x7B)=>chr(0x05F0), #HEBREW LIGATURE YIDDISH DOUBLE VAV / TSVEY VOVN
chr(0x7C)=>chr(0x05F1), #HEBREW LIGATURE YIDDISH VAV YOD / VOV YUD
chr(0x7D)=>chr(0x05F2), #HEBREW LIGATURE YIDDISH DOUBLE YOD / TSVEY YUDN

);

%combining = (
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
