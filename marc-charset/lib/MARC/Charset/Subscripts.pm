package MARC::Charset::Subscripts;

=head1 NAME

MARC::Charset::Subscripts - MARC8/UTF8 mapping for Subscripts

=head1 SYNOPSIS

 use MARC::Charset::Subscripts;
 my $cs = MARC::Charset::Subscripts->new();

=head1 DESCRIPTION

MARC::Charset::Subscripts provides a mapping between the MARC8 Subscript 
character set and Unicode(UTF8). It is typically used by MARC::Charset, so you 
probably don't need to use this yourself. 

=head1 METHODS

=cut 

use strict;
use utf8;
use constant CHAR_SIZE	    => 1;
my %marc2unicode;

=head1 

The constructor, which will return you a MARC::Charset::Subscripts object.

=cut


sub new {
    my $class = shift;
    return bless {}, ref($class) || $class;
}

=head1 name()

Returns the name of the character set.

=cut


sub name {
    return('Subscripts');
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
    return(undef); ## no combining chars
}

=head1 getCharSize()

Returns the number of bytes in each character of this character set.

=cut


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
