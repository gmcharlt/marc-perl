package MARC::Charset::Superscripts;

=head1 NAME

MARC::Charset::Superscripts - MARC8/UTF8 mapping for Superscripts

=head1 SYNOPSIS

 use MARC::Charset::Superscripts;
 my $cs = MARC::Charset::Superscripts->new();

=head1 DESCRIPTION

MARC::Charset::Superscripts provides a mapping between the MARC8 Superscript 
character set and Unicode(UTF8). It is typically used by MARC::Charset, so 
you probably don't need to use this yourself. 

=head1 METHODS

=cut 

use strict;
use utf8;
use constant CHAR_SIZE	    => 1;
my %marc2unicode;

=head1 

The constructor, which will return you a MARC::Charset::Superscript object.

=cut


sub new {
    my $class = shift;
    return bless {}, ref($class) || $class;
}

=head1 name()

Returns the name of the character set.

=cut


sub name {
    return('Superscripts');
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
    return(undef);
}

=head1 getCharSize()

Returns the number of bytes in each character of this character set.

=cut


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
