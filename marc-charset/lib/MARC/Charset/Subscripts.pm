package MARC::Charset::Subscripts;

use strict;
use utf8;
use constant CHAR_SIZE	    => 1;
my %marc2unicode;

sub new {
    my $class = shift;
    return bless {}, ref($class) || $class;
}

sub name {
    return('Subscripts');
}

sub lookup {
    my ($self,$char) = @_; 
    return($marc2unicode{$char});
}

sub combining {
    return(undef); ## no combining chars
}

sub getCharSize {
    return(CHAR_SIZE);
}


%marc2unicode = (

chr(0x28)=>chr(0x208D),  #SUBSCRIPT OPENING PAREN / SUBSCRIPT LEFT PARENTHESIS
chr(0x29)=>chr(0x208E),  #SUBSCRIPT CLOSING PAREN / SUBSCRIPT RIGHT PARENTHESIS
chr(0x2B)=>chr(0x208A),  #SUBSCRIPT PLUS SIGN
chr(0x2D)=>chr(0x208B),  #SUBSCRIPT HYPHEN-MINUS / SUBSCRIPT MINUS
chr(0x30)=>chr(0x2080),  #SUBSCRIPT DIGIT ZERO
chr(0x31)=>chr(0x2081),  #SUBSCRIPT DIGIT ONE
chr(0x32)=>chr(0x2082),  #SUBSCRIPT DIGIT TWO
chr(0x33)=>chr(0x2083),  #SUBSCRIPT DIGIT THREE
chr(0x34)=>chr(0x2084),  #SUBSCRIPT DIGIT FOUR
chr(0x35)=>chr(0x2085),  #SUBSCRIPT DIGIT FIVE
chr(0x36)=>chr(0x2086),  #SUBSCRIPT DIGIT SIX
chr(0x37)=>chr(0x2087),  #SUBSCRIPT DIGIT SEVEN
chr(0x38)=>chr(0x2088),  #SUBSCRIPT DIGIT EIGHT
chr(0x39)=>chr(0x2089),  #SUBSCRIPT DIGIT NINE
 
);

1;
