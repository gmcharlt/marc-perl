package MARC::Charset::Ansel;

=head1 NAME

MARC::Charset::Ansel - MARC8/UTF8 mappings for Ansel

=head1 SYNOPSIS

 use MARC::Charset::Ansel;
 my $cs = MARC::Charset::Ansel->new();

=head1 DESCRIPTION

MARC::Charset::Ansel provides a mapping between the MARC8 Ansel character
set and Unicode(UTF8). It is typically used by MARC::Charset, so you 
probably don't need to use this yourself. 

=head1 METHODS

=cut 

use strict;
use constant CHAR_SIZE	    => 1;
our %marc2unicode;
our %combining;

=head1 

The constructor, which will return you a MARC::Charset::Ansel object.

=cut


sub new {
    my $class = shift;
    return bless {}, ref($class) || $class;
}

=head1 name()

Returns the name of the character set.

=cut

sub name {
    return('Ansel');
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
    return( $combining{$char} );
}

=head1 getCharSize()

Returns the number of bytes in each character of this character set.

=cut


sub getCharSize {
    return(CHAR_SIZE);
}

%marc2unicode = (

chr(0xA1)=>chr(0x0141), # UPPERCASE POLISH L / LATIN CAPITAL L WITH STROKE
chr(0xA2)=>chr(0x00D8), # UPPERCASE SCANDINAV O / LATIN CAPITAL O WITH STROKE
chr(0xA3)=>chr(0x0110), # UPPERCASE D WITH CROSSBAR / LATIN CAP D WITH STROKE
chr(0xA4)=>chr(0x00DE), # UPPERCASE ICELAND THORN / LATIN CAP THORN (Icelandic)
chr(0xA5)=>chr(0x00C6), # UPPERCASE DIGRAPH AE / LATIN CAPITAL LIGATURE AE
chr(0xA6)=>chr(0x0152), # UPPERCASE DIGRAPH OE / LATIN CAPITAL LIGATURE OE
chr(0xA7)=>chr(0x02B9), # SOFT SIGN, PRIME / MODIFIER LETTER PRIME
chr(0xA8)=>chr(0x00B7), # MIDDLE DOT
chr(0xA9)=>chr(0x266D), # MUSIC FLAT SIGN
chr(0xAA)=>chr(0x00AE), # PATENT MARK / REGISTERED SIGN
chr(0xAB)=>chr(0x00B1), # PLUS OR MINUS / PLUS-MINUS SIGN
chr(0xAC)=>chr(0x01A0), # UPPERCASE O-HOOK / LATIN CAPITAL LETTER O WITH HORN
chr(0xAD)=>chr(0x01AF), # UPPERCASE U-HOOK / LATIN CAPITAL LETTER U WITH HORN
chr(0xAE)=>chr(0x02BE), # ALIF / MODIFIER LETTER RIGHT HALF RING
chr(0xB0)=>chr(0x02BB), # AYN / MODIFIER LETTER TURNED COMMA
chr(0xB1)=>chr(0x0142), # LOWERCASE POLISH L / LATIN SMALL LETTER L WITH STROKE
chr(0xB2)=>chr(0x00F8), # LOWERCASE SCANDINAVIAN O / LATIN SMALL O WITH STROKE
chr(0xB3)=>chr(0x0111), # LOWERCASE D WITH CROSSBAR / LATIN SMALL D WITH STROKE
chr(0xB4)=>chr(0x00FE), # LOWERCASE ICEL THORN / LATIN SMALL THORN (Icelandic)
chr(0xB5)=>chr(0x00E6), # LOWERCASE DIGRAPH AE / LATIN SMALL LIGATURE AE
chr(0xB6)=>chr(0x0153), # LOWERCASE DIGRAPH OE / LATIN SMALL LIGATURE OE
chr(0xB7)=>chr(0x02BA), # HARD SIGN, DOUBLE PRIME / MODIFIER LETTER DOUBLE PRIME
chr(0xB8)=>chr(0x0131), # LOWERCASE TURKISH I / LATIN SMALL LETTER DOTLESS I
chr(0xB9)=>chr(0x00A3), # BRITISH POUND / POUND SIGN
chr(0xBA)=>chr(0x00F0), # LOWERCASE ETH / LATIN SMALL LETTER ETH (Icelandic)
chr(0xBC)=>chr(0x01A1), # LOWERCASE O-HOOK / LATIN SMALL LETTER O WITH HORN
chr(0xBD)=>chr(0x01B0), # LOWERCASE U-HOOK / LATIN SMALL LETTER U WITH HORN
chr(0xC0)=>chr(0x00B0), # DEGREE SIGN
chr(0xC1)=>chr(0x2113), # SCRIPT SMALL L
chr(0xC2)=>chr(0x2117), # SOUND RECORDING COPYRIGHT
chr(0xC3)=>chr(0x00A9), # COPYRIGHT SIGN
chr(0xC4)=>chr(0x266F), # MUSIC SHARP SIGN
chr(0xC5)=>chr(0x00BF), # INVERTED QUESTION MARK
chr(0xC6)=>chr(0x00A1), # INVERTED EXCLAMATION MARK
chr(0xE0)=>chr(0x0309), # PSEUDO QUESTION MARK / COMBINING HOOK ABOVE
chr(0xE1)=>chr(0x0300), # GRAVE / COMBINING GRAVE ACCENT (Varia)
chr(0xE2)=>chr(0x0301), # ACUTE / COMBINING ACUTE ACCENT (Oxia)
chr(0xE3)=>chr(0x0302), # CIRCUMFLEX / COMBINING CIRCUMFLEX ACCENT
chr(0xE4)=>chr(0x0303), # TILDE / COMBINING TILDE
chr(0xE5)=>chr(0x0304), # MACRON / COMBINING MACRON
chr(0xE6)=>chr(0x0306), # BREVE / COMBINING BREVE (Vrachy)
chr(0xE7)=>chr(0x0307), # SUPERIOR DOT / COMBINING DOT ABOVE
chr(0xE8)=>chr(0x0308), # UMLAUT, DIAERESIS / COMBINING DIAERESIS (Dialytika)
chr(0xE9)=>chr(0x030C), # HACEK / COMBINING CARON
chr(0xEA)=>chr(0x030A), # CIRCLE ABOVE, ANGSTROM / COMBINING RING ABOVE
chr(0xEB)=>chr(0xFE20), # LIGATURE, FIRST HALF / COMBINING LIGATURE LEFT HALF
chr(0xEC)=>chr(0xFE21), # LIGATURE, SECOND HALF / COMBINING LIGATURE RIGHT HALF
chr(0xED)=>chr(0x0315), # HIGH COMMA, OFF CENTER / COMBINING COMMA ABOVE RIGHT
chr(0xEE)=>chr(0x030B), # DOUBLE ACUTE / COMBINING DOUBLE ACUTE ACCENT
chr(0xEF)=>chr(0x0310), # CANDRABINDU / COMBINING CANDRABINDU
chr(0xF0)=>chr(0x0327), # CEDILLA / COMBINING CEDILLA
chr(0xF1)=>chr(0x0328), # RIGHT HOOK, OGONEK / COMBINING OGONEK
chr(0xF2)=>chr(0x0323), # DOT BELOW / COMBINING DOT BELOW
chr(0xF3)=>chr(0x0324), # DOUBLE DOT BELOW / COMBINING DIAERESIS BELOW
chr(0xF4)=>chr(0x0325), # CIRCLE BELOW / COMBINING RING BELOW
chr(0xF5)=>chr(0x0333), # DOUBLE UNDERSCORE / COMBINING DOUBLE LOW LINE
chr(0xF6)=>chr(0x0332), # UNDERSCORE / COMBINING LOW LINE
chr(0xF7)=>chr(0x0326), # LEFT HOOK (COMMA BELOW) / COMBINING COMMA BELOW
chr(0xF8)=>chr(0x031C), # RIGHT CEDILLA / COMBINING LEFT HALF RING BELOW
chr(0xF9)=>chr(0x032E), # UPADHMANIYA / COMBINING BREVE BELOW
chr(0xFA)=>chr(0xFE22), # DOUBLE TILDE, FIRST HALF / COMB DOUBLE TILDE LEFT HALF
chr(0xFB)=>chr(0xFE23), # DOUBLE TILDE, SECOND HALF / COMB DBLE TILDE RIGHT HALF
chr(0xFE)=>chr(0x0313), # HIGH COMMA, CENTERED / COMBINING COMMA ABOVE (Psili)

);

%combining = (

chr(0xE0) => 1, # PSEUDO QUESTION MARK / COMBINING HOOK ABOVE
chr(0xE1) => 1, # GRAVE / COMBINING GRAVE ACCENT (Varia)
chr(0xE2) => 1, # ACUTE / COMBINING ACUTE ACCENT (Oxia)
chr(0xE3) => 1, # CIRCUMFLEX / COMBINING CIRCUMFLEX ACCENT
chr(0xE4) => 1, # TILDE / COMBINING TILDE
chr(0xE5) => 1, # MACRON / COMBINING MACRON
chr(0xE6) => 1, # BREVE / COMBINING BREVE (Vrachy)
chr(0xE7) => 1, # SUPERIOR DOT / COMBINING DOT ABOVE
chr(0xE8) => 1, # UMLAUT, DIAERESIS / COMBINING DIAERESIS (Dialytika)
chr(0xE9) => 1, # HACEK / COMBINING CARON
chr(0xEA) => 1, # CIRCLE ABOVE, ANGSTROM / COMBINING RING ABOVE
chr(0xEB) => 1, # LIGATURE, FIRST HALF / COMBINING LIGATURE LEFT HALF
chr(0xEC) => 1, # LIGATURE, SECOND HALF / COMBINING LIGATURE RIGHT HALF
chr(0xED) => 1, # HIGH COMMA, OFF CENTER / COMBINING COMMA ABOVE RIGHT
chr(0xEE) => 1, # DOUBLE ACUTE / COMBINING DOUBLE ACUTE ACCENT
chr(0xEF) => 1, # CANDRABINDU / COMBINING CANDRABINDU
chr(0xF0) => 1, # CEDILLA / COMBINING CEDILLA
chr(0xF1) => 1, # RIGHT HOOK, OGONEK / COMBINING OGONEK
chr(0xF2) => 1, # DOT BELOW / COMBINING DOT BELOW
chr(0xF3) => 1, # DOUBLE DOT BELOW / COMBINING DIAERESIS BELOW
chr(0xF4) => 1, # CIRCLE BELOW / COMBINING RING BELOW
chr(0xF5) => 1, # DOUBLE UNDERSCORE / COMBINING DOUBLE LOW LINE
chr(0xF6) => 1, # UNDERSCORE / COMBINING LOW LINE
chr(0xF7) => 1, # LEFT HOOK (COMMA BELOW) / COMBINING COMMA BELOW
chr(0xF8) => 1, # RIGHT CEDILLA / COMBINING LEFT HALF RING BELOW
chr(0xF9) => 1, # UPADHMANIYA / COMBINING BREVE BELOW
chr(0xFA) => 1, # DOUBLE TILDE, FIRST HALF / COMB DOUBLE TILDE LEFT HALF
chr(0xFB) => 1, # DOUBLE TILDE, SECOND HALF / COMB DBLE TILDE RIGHT HALF
chr(0xFE) => 1, # HIGH COMMA, CENTERED / COMBINING COMMA ABOVE (Psili)

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
