package MARC::Charset::GreekSymbols;

use strict;
use utf8;
use constant CHAR_SIZE	    => 1;
my %marc2unicode;

sub new {
    my $class = shift;
    return bless {}, ref($class) || $class;
}

sub name {
    return('Greek-Symbols');
}

sub lookup {
    my ($self,$char) = @_; 
    return($marc2unicode{$char});
}

sub combining {
    return(undef); ## aren't any
}

sub getCharSize {
    return(CHAR_SIZE);
}

#                 MARC 21 Specifications for Record Structure,
#                      Character Sets, and Exchange Media
#                            CHARACTER SETS: Part 3
# 
#                          Code Table 2: GREEK SYMBOLS
# 
#                                 January 2000
#   ------------------------------------------------------------------------
#   ------------------------------------------------------------------------
# 
# The first column in each table contains the MARC 8-bit code (in hex), the
# second column the UCS/Unicode 16-bit code (in hex), and the third column
# contains the character names: MARC name / UCS name. If the MARC name is the
# same as or very similar to the UCS name, only the UCS name is given.
# 
#   ------------------------------------------------------------------------
# 
# GREEK SYMBOLS

%marc2unicode = (

chr(0x61)=>chr(0x03B1),  #GREEK SMALL LETTER ALPHA
chr(0x62)=>chr(0x03B2),  #GREEK SMALL LETTER BETA
chr(0x63)=>chr(0x03B3),  #GREEK SMALL LETTER GAMMA

);

1;
