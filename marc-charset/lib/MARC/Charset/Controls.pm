package MARC::Charset::Controls;

use strict;
use utf8;
use constant CHAR_SIZE	    => 1;
our %marc2unicode;

sub new {
    my $class = shift;
    return bless {}, ref($class) || $class;
}

sub name {
    return('Controls');
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

chr(0x1B)=>chr(0x001B), # ESCAPE (Unlikely to occur in UCS/Unicode)
chr(0x1D)=>chr(0x001D), # RECORD TERMINATOR / GROUP SEPARATOR
chr(0x1E)=>chr(0x001E), # FIELD TERMINATOR / RECORD SEPARATOR
chr(0x1F)=>chr(0x001F), # SUBFIELD DELIMITER / UNIT SEPARATOR
chr(0x20)=>chr(0x0020), # SPACE
chr(0x88)=>chr(0x0098), # NON-SORT BEGIN / START OF STRING
chr(0x89)=>chr(0x009C), # NON-SORT END / STRING TERMINATOR
chr(0x8D)=>chr(0x200D), # JOINER / ZERO WIDTH JOINER
chr(0x8E)=>chr(0x200C), # NON-JOINER / ZERO WIDTH NON-JOINER

);

1;
