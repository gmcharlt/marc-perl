package MARC::Charset::Greek;

=head1 NAME

MARC::Charset::Greek - MARC8/UTF8 mappings 

=head1 SYNOPSIS

 use MARC::Charset::Greek;
 my $cs = MARC::Charset::Greek->new();

=head1 DESCRIPTION

MARC::Charset::Greek provides a mapping between the MARC8 Greek character
set and Unicode(UTF8). It is typically used by MARC::Charset, so you 
probably don't need to use this yourself. 

=head1 METHODS

=cut 

use strict;
use utf8;
use constant CHAR_SIZE	    => 1;
my %marc2unicode;
my %combining;

=head1 

The constructor, which will return you a MARC::Charset::Greek object.

=cut


sub new {
    my $class = shift;
    return bless {}, ref($class) || $class;
}

=head1 name()

Returns the name of the character set.

=cut


sub name {
    return('Greek');
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
    my ($self,$char) = @_;
    return($combining{$char}) 
}

=head1 getCharSize()

Returns the number of bytes in each character of this character set.

=cut


sub getCharSize {
    return(CHAR_SIZE);
}


%marc2unicode = (

chr(0x21)=>chr(0x0300), #COMBINING GRAVE ACCENT
chr(0x22)=>chr(0x0301), #COMBINING ACUTE ACCENT
chr(0x23)=>chr(0x0308), #COMBINING DIAERESIS
chr(0x24)=>chr(0x0342), #COMBINING GREEK PERISPOMENI / CIRCUMFLEX
chr(0x25)=>chr(0x0313), #COMBINING COMMA ABOVE / SMOOTH BREATHING
chr(0x26)=>chr(0x0314), #COMBINING REVERSED COMMA ABOVE / ROUGH BREATHING
chr(0x27)=>chr(0x0345), #COMBINING GREEK YPOGEGRAMMENI / IOTA SUBSCRIPT
chr(0x30)=>chr(0x00AB), #LEFT-POINTING DOUBLE ANGLE QUOTATION MARK
chr(0x31)=>chr(0x00BB), #RIGHT-POINTING DOUBLE ANGLE QUOTATION MARK
chr(0x32)=>chr(0x201C), #LEFT DOUBLE QUOTATION MARK
chr(0x33)=>chr(0x201D), #RIGHT DOUBLE QUOTATION MARK
chr(0x34)=>chr(0x0374), #GREEK NUMERAL SIGN / UPPER PRIME
chr(0x35)=>chr(0x0375), #GREEK LOWER NUMERAL SIGN / LOWER PRIME
chr(0x3B)=>chr(0x0387), #GREEK ANO TELEIA / RAISED DOT, GREEK SEMICOLON
chr(0x3F)=>chr(0x037E), #GREEK QUESTION MARK
chr(0x41)=>chr(0x0391), #GREEK CAPITAL LETTER ALPHA
chr(0x42)=>chr(0x0392), #GREEK CAPITAL LETTER BETA
chr(0x44)=>chr(0x0393), #GREEK CAPITAL LETTER GAMMA
chr(0x45)=>chr(0x0394), #GREEK CAPITAL LETTER DELTA
chr(0x46)=>chr(0x0395), #GREEK CAPITAL LETTER EPSILON
chr(0x47)=>chr(0x03DA), #GREEK LETTER STIGMA
chr(0x48)=>chr(0x03DC), #GREEK LETTER DIGAMMA
chr(0x49)=>chr(0x0396), #GREEK CAPITAL LETTER ZETA
chr(0x4A)=>chr(0x0397), #GREEK CAPITAL LETTER ETA
chr(0x4B)=>chr(0x0398), #GREEK CAPITAL LETTER THETA
chr(0x4C)=>chr(0x0399), #GREEK CAPITAL LETTER IOTA
chr(0x4D)=>chr(0x039A), #GREEK CAPITAL LETTER KAPPA
chr(0x4E)=>chr(0x039B), #GREEK CAPITAL LETTER LAMDA
chr(0x4F)=>chr(0x039C), #GREEK CAPITAL LETTER MU
chr(0x50)=>chr(0x039D), #GREEK CAPITAL LETTER NU
chr(0x51)=>chr(0x039E), #GREEK CAPITAL LETTER XI
chr(0x52)=>chr(0x039F), #GREEK CAPITAL LETTER OMICRON
chr(0x53)=>chr(0x03A0), #GREEK CAPITAL LETTER PI
chr(0x54)=>chr(0x03DE), #GREEK LETTER KOPPA
chr(0x55)=>chr(0x03A1), #GREEK CAPITAL LETTER RHO
chr(0x56)=>chr(0x03A3), #GREEK CAPITAL LETTER SIGMA
chr(0x58)=>chr(0x03A4), #GREEK CAPITAL LETTER TAU
chr(0x59)=>chr(0x03A5), #GREEK CAPITAL LETTER UPSILON
chr(0x5A)=>chr(0x03A6), #GREEK CAPITAL LETTER PHI
chr(0x5B)=>chr(0x03A7), #GREEK CAPITAL LETTER CHI
chr(0x5C)=>chr(0x03A8), #GREEK CAPITAL LETTER PSI
chr(0x5D)=>chr(0x03A9), #GREEK CAPITAL LETTER OMEGA
chr(0x5E)=>chr(0x03E0), #GREEK LETTER SAMPI
chr(0x61)=>chr(0x03B1), #GREEK SMALL LETTER ALPHA
chr(0x62)=>chr(0x03B2), #GREEK SM LETT BETA / SM LETTER BETA BEGINNING OF WORD
chr(0x63)=>chr(0x03D0), #GREEK BETA SYMBOL / SMALL LETTER BETA MIDDLE OF WORD
chr(0x64)=>chr(0x03B3), #GREEK SMALL LETTER GAMMA
chr(0x65)=>chr(0x03B4), #GREEK SMALL LETTER DELTA
chr(0x66)=>chr(0x03B5), #GREEK SMALL LETTER EPSILON
chr(0x67)=>chr(0x03DB), #GREEK SMALL LETTER STIGMA
chr(0x68)=>chr(0x03DD), #GREEK SMALL LETTER DIGAMMA
chr(0x69)=>chr(0x03B6), #GREEK SMALL LETTER ZETA
chr(0x6A)=>chr(0x03B7), #GREEK SMALL LETTER ETA
chr(0x6B)=>chr(0x03B8), #GREEK SMALL LETTER THETA
chr(0x6C)=>chr(0x03B9), #GREEK SMALL LETTER IOTA
chr(0x6D)=>chr(0x03BA), #GREEK SMALL LETTER KAPPA
chr(0x6E)=>chr(0x03BB), #GREEK SMALL LETTER LAMDA
chr(0x6F)=>chr(0x03BC), #GREEK SMALL LETTER MU
chr(0x70)=>chr(0x03BD), #GREEK SMALL LETTER NU
chr(0x71)=>chr(0x03BE), #GREEK SMALL LETTER XI
chr(0x72)=>chr(0x03BF), #GREEK SMALL LETTER OMICRON
chr(0x73)=>chr(0x03C0), #GREEK SMALL LETTER PI
chr(0x74)=>chr(0x03DF), #GREEK SMALL LETTER KOPPA
chr(0x75)=>chr(0x03C1), #GREEK SMALL LETTER RHO
chr(0x76)=>chr(0x03C3), #GREEK SMALL LETTER SIGMA
chr(0x77)=>chr(0x03C2), #GREEK SM LETT FINAL SIGMA / SM LETT SIGMA END OF WORD
chr(0x78)=>chr(0x03C4), #GREEK SMALL LETTER TAU
chr(0x79)=>chr(0x03C5), #GREEK SMALL LETTER UPSILON
chr(0x7A)=>chr(0x03C6), #GREEK SMALL LETTER PHI
chr(0x7B)=>chr(0x03C7), #GREEK SMALL LETTER CHI
chr(0x7C)=>chr(0x03C8), #GREEK SMALL LETTER PSI
chr(0x7D)=>chr(0x03C9), #GREEK SMALL LETTER OMEGA
chr(0x7E)=>chr(0x03E1), #GREEK SMALL LETTER SAMPI

);

%combining = (

chr(0x21)=>1, #COMBINING GRAVE ACCENT
chr(0x22)=>1, #COMBINING ACUTE ACCENT
chr(0x23)=>1, #COMBINING DIAERESIS
chr(0x24)=>1, #COMBINING GREEK PERISPOMENI / CIRCUMFLEX
chr(0x25)=>1, #COMBINING COMMA ABOVE / SMOOTH BREATHING
chr(0x26)=>1, #COMBINING REVERSED COMMA ABOVE / ROUGH BREATHING
chr(0x27)=>1, #COMBINING GREEK YPOGEGRAMMENI / IOTA SUBSCRIPT

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
