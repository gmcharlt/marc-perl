package MARC::Charset::ArabicExtended;

use MARC::Charset::Generic qw( :all );
use base qw( MARC::Charset::Generic );

=head1 NAME

MARC::Charset::ArabicExtended - MARC8/UTF8 mappings for Extended Arabic

=head1 SYNOPSIS

 use MARC::Charset::ArabicExtended;
 my $cs = MARC::Charset::ArabicExtended->new();

=head1 DESCRIPTION

MARC::Charset::ArabicExtended provides a mapping between the MARC8 Extended 
Arabic character set and Unicode(UTF8). It is typically used by MARC::Charset, 
so you probably don't need to use this yourself. It inherits from
MARC::Charset::Generic, so to see all the methods you can call you need to look
at those docs.

=head1 METHODS

=cut 

use strict;
our %marc2unicode;
our %combining;

=head1 

The constructor, which will return you a MARC::Charset::ArabicExtended object.

=cut


sub new {
    my $class = shift;
    return bless 
	{
	    NAME	=> 'Arabic-Extended',
	    CHARSETCODE	=> EXTENDED_ARABIC,
	    CHARSIZE	=> 1
	}, ref($class) || $class;
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
    return($combining{$char});
}

%marc2unicode = (

chr(0xA1)=>chr(0x06FD), #DOUBLE ALEF WITH HAMZA ABOVE / ARABIC SIGN SINDHI AMPERSAND
chr(0xA2)=>chr(0x0672), #ARABIC LETTER ALEF WITH WAVY HAMZA ABOVE
chr(0xA3)=>chr(0x0673), #ARABIC LETTER ALEF WITH WAVY HAMZA BELOW
chr(0xA4)=>chr(0x0679), #ARABIC LETTER TTEH
chr(0xA5)=>chr(0x067A), #ARABIC LETTER TTEHEH
chr(0xA6)=>chr(0x067B), #ARABIC LETTER BBEH
chr(0xA7)=>chr(0x067C), #ARABIC LETTER TEH WITH RING
chr(0xA8)=>chr(0x067D), #ARABIC LETTER TEH WITH THREE DOTS ABOVE DOWNWARDS
chr(0xA9)=>chr(0x067E), #ARABIC LETTER PEH
chr(0xAA)=>chr(0x067F), #ARABIC LETTER TEHEH
chr(0xAB)=>chr(0x0680), #ARABIC LETTER BEHEH
chr(0xAC)=>chr(0x0681), #ARABIC LETTER HAH WITH HAMZA ABOVE
chr(0xAD)=>chr(0x0682), #ARABIC LETTER HAH WITH TWO ABOVE DOTS VERTICAL ABOVE
chr(0xAE)=>chr(0x0683), #ARABIC LETTER NYEH
chr(0xAF)=>chr(0x0684), #ARABIC LETTER DYEH
chr(0xB0)=>chr(0x0685), #ARABIC LETTER HAH WITH THREE DOTS ABOVE
chr(0xB1)=>chr(0x0686), #ARABIC LETTER TCHEH
chr(0xB2)=>chr(0x06BF), #ARABIC LETTER TCHEH WITH DOT ABOVE
chr(0xB3)=>chr(0x0687), #ARABIC LETTER TCHEHEH
chr(0xB4)=>chr(0x0688), #ARABIC LETTER DDAL
chr(0xB5)=>chr(0x0689), #ARABIC LETTER DAL WITH RING
chr(0xB6)=>chr(0x068A), #ARABIC LETTER DAL WITH DOT BELOW
chr(0xB7)=>chr(0x068B), #ARABIC LETTER DAL WITH DOT BELOW AND SMALL TAH
chr(0xB8)=>chr(0x068C), #ARABIC LETTER DAHAL
chr(0xB9)=>chr(0x068D), #ARABIC LETTER DDAHAL
chr(0xBA)=>chr(0x068E), #ARABIC LETTER DUL
chr(0xBB)=>chr(0x068F), #ARABIC LETTER DAL WITH THREE DOTS ABOVE DOWNWARDS
chr(0xBC)=>chr(0x0690), #ARABIC LETTER DAL WITH FOUR DOTS ABOVE
chr(0xBD)=>chr(0x0691), #ARABIC LETTER RREH
chr(0xBE)=>chr(0x0692), #ARABIC LETTER REH WITH SMALL V
chr(0xBF)=>chr(0x0693), #ARABIC LETTER REH WITH RING
chr(0xC0)=>chr(0x0694), #ARABIC LETTER REH WITH DOT BELOW
chr(0xC1)=>chr(0x0695), #ARABIC LETTER REH WITH SMALL V BELOW
chr(0xC2)=>chr(0x0696), #ARABIC LETTER REH WITH DOT BELOW AND DOT ABOVE
chr(0xC3)=>chr(0x0697), #ARABIC LETTER REH WITH TWO DOTS ABOVE
chr(0xC4)=>chr(0x0698), #ARABIC LETTER JEH
chr(0xC5)=>chr(0x0699), #ARABIC LETTER REH WITH FOUR DOTS ABOVE
chr(0xC6)=>chr(0x069A), #ARABIC LETTER SEEN WITH DOT BELOW AND DOT ABOVE
chr(0xC7)=>chr(0x069B), #ARABIC LETTER SEEN WITH THREE DOTS BELOW
chr(0xC8)=>chr(0x069C), #ARABIC LETT SEEN WITH 3 DOTS BELOW AND 3 DOTS ABOVE
chr(0xC9)=>chr(0x06FA), #ARABIC LETTER SHEEN WITH DOT BELOW
chr(0xCA)=>chr(0x069D), #ARABIC LETTER SAD WITH TWO DOTS BELOW
chr(0xCB)=>chr(0x069E), #ARABIC LETTER SAD WITH THREE DOTS ABOVE
chr(0xCC)=>chr(0x06FB), #ARABIC LETTER DAD WITH DOT BELOW
chr(0xCD)=>chr(0x069F), #ARABIC LETTER TAH WITH THREE DOTS ABOVE
chr(0xCE)=>chr(0x06A0), #ARABIC LETTER AIN WITH THREE DOTS ABOVE
chr(0xCF)=>chr(0x06FC), #ARABIC LETTER GHAIN WITH DOT BELOW
chr(0xD0)=>chr(0x06A1), #ARABIC LETTER DOTLESS FEH
chr(0xD1)=>chr(0x06A2), #ARABIC LETTER FEH WITH DOT MOVED BELOW
chr(0xD2)=>chr(0x06A3), #ARABIC LETTER FEH WITH DOT BELOW
chr(0xD3)=>chr(0x06A4), #ARABIC LETTER VEH
chr(0xD4)=>chr(0x06A5), #ARABIC LETTER FEH WITH THREE DOTS BELOW
chr(0xD5)=>chr(0x06A6), #ARABIC LETTER PEHEH
chr(0xD6)=>chr(0x06A7), #ARABIC LETTER QAF WITH DOT ABOVE
chr(0xD7)=>chr(0x06A8), #ARABIC LETTER QAF WITH THREE DOTS ABOVE
chr(0xD8)=>chr(0x06A9), #ARABIC LETTER KEHEH
chr(0xD9)=>chr(0x06AA), #ARABIC LETTER SWASH KAF
chr(0xDA)=>chr(0x06AB), #ARABIC LETTER KAF WITH RING
chr(0xDB)=>chr(0x06AC), #ARABIC LETTER KAF WITH DOT ABOVE
chr(0xDC)=>chr(0x06AD), #ARABIC LETTER NG
chr(0xDD)=>chr(0x06AE), #ARABIC LETTER KAF WITH THREE DOTS BELOW
chr(0xDE)=>chr(0x06AF), #ARABIC LETTER GAF
chr(0xDF)=>chr(0x06B0), #ARABIC LETTER GAF WITH RING
chr(0xE0)=>chr(0x06B1), #ARABIC LETTER NGOEH
chr(0xE1)=>chr(0x06B2), #ARABIC LETTER GAF WITH TWO DOTS BELOW
chr(0xE2)=>chr(0x06B3), #ARABIC LETTER GUEH
chr(0xE3)=>chr(0x06B4), #ARABIC LETTER GAF WITH THREE DOTS ABOVE
chr(0xE4)=>chr(0x06B5), #ARABIC LETTER LAM WITH SMALL V
chr(0xE5)=>chr(0x06B6), #ARABIC LETTER LAM WITH DOT ABOVE
chr(0xE6)=>chr(0x06B7), #ARABIC LETTER LAM WITH THREE DOTS ABOVE
chr(0xE7)=>chr(0x06B8), #ARABIC LETTER LAM WITH THREE DOTS BELOW
chr(0xE8)=>chr(0x06BA), #ARABIC LETTER NOON GHUNNA
chr(0xE9)=>chr(0x06BB), #ARABIC LETTER RNOON
chr(0xEA)=>chr(0x06BC), #ARABIC LETTER NOON WITH RING
chr(0xEB)=>chr(0x06BD), #ARABIC LETTER NOON WITH THREE DOTS ABOVE
chr(0xEC)=>chr(0x06B9), #ARABIC LETTER NOON WITH DOT BELOW
chr(0xED)=>chr(0x06BE), #ARABIC LETTER HEH DOACHASHMEE
chr(0xEE)=>chr(0x06C0), #HEH WITH HAMZA ABOVE / ARABIC LETTER HEH WITH YEH ABOVE
chr(0xEF)=>chr(0x06C4), #ARABIC LETTER WAW WITH RING
chr(0xF0)=>chr(0x06C5), #KYRGHYZ OE / ARABIC LETTER KIRGHIZ OE
chr(0xF1)=>chr(0x06C6), #ARABIC LETTER OE
chr(0xF2)=>chr(0x06CA), #ARABIC LETTER WAW WITH TWO DOTS ABOVE
chr(0xF3)=>chr(0x06CB), #ARABIC LETTER VE
chr(0xF4)=>chr(0x06CD), #ARABIC LETTER YEH WITH TAIL
chr(0xF5)=>chr(0x06CE), #ARABIC LETTER YEH WITH SMALL V
chr(0xF6)=>chr(0x06D0), #ARABIC LETTER E
chr(0xF7)=>chr(0x06D2), #ARABIC LETTER YEH BARREE
chr(0xF8)=>chr(0x06D3), #ARABIC LETTER YEH BARREE WITH HAMZA ABOVE
chr(0xFD)=>chr(0x0306), #SHORT E / COMBINING BREVE
chr(0xFE)=>chr(0x030C), #SHORT U / COMBINING CARON

);

%combining = (

chr(0xFD)=>1, #SHORT E / COMBINING BREVE
chr(0xFE)=>1, #SHORT U / COMBINING CARON

);

=head1 TODO

=over 4 

=item Nothing 

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
