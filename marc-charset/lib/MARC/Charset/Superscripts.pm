package MARC::Charset::Superscripts;

use strict;
use utf8;
use constant CHAR_SIZE	    => 1;
my %marc2unicode;

sub new {
    my $class = shift;
    return bless {}, ref($class) || $class;
}

sub name {
    return('Superscripts');
}

sub lookup {
    my ($self,$char) = @_; 
    return($marc2unicode{$char}); 
}

sub combining {
    return(undef);
}

sub getCharSize {
    return(CHAR_SIZE);
}

%marc2unicode = (

chr(0x28)=>chr(0x207D), #SUPERSCRIPT OPENING PAREN / SUPERSCRIPT LEFT PAREN
chr(0x29)=>chr(0x207E), #SUPERSCRIPT CLOSING PAREN / SUPERSCRIPT RIGHT PAREN
chr(0x2B)=>chr(0x207A), #SUPERSCRIPT PLUS SIGN
chr(0x2D)=>chr(0x207B), #SUPERSCRIPT HYPHEN-MINUS / SUPERSCRIPT MINUS
chr(0x30)=>chr(0x2070), #SUPERSCRIPT DIGIT ZERO
chr(0x31)=>chr(0x00B9), #SUPERSCRIPT DIGIT ONE
chr(0x32)=>chr(0x00B2), #SUPERSCRIPT DIGIT TWO
chr(0x33)=>chr(0x00B3), #SUPERSCRIPT DIGIT THREE
chr(0x34)=>chr(0x2074), #SUPERSCRIPT DIGIT FOUR
chr(0x35)=>chr(0x2075), #SUPERSCRIPT DIGIT FIVE
chr(0x36)=>chr(0x2076), #SUPERSCRIPT DIGIT SIX
chr(0x37)=>chr(0x2077), #SUPERSCRIPT DIGIT SEVEN
chr(0x38)=>chr(0x2078), #SUPERSCRIPT DIGIT EIGHT
chr(0x39)=>chr(0x2079), #SUPERSCRIPT DIGIT NINE

);

1;
