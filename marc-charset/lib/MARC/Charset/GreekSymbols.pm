package MARC::Charset::GreekSymbols;

=head1 NAME

MARC::Charset::GreekSymbols - MARC8/UTF8 character encodings for Greek Symbols

=head1 SYNOPSIS

 use MARC::Charset::GreekSymbols;
 my $cs = MARC::Charset::GreekSymbols->new();

=head1 DESCRIPTION

MARC::Charset::GreekSymbols provides a mapping between the MARC8 Greek Symbol 
character set and Unicode(UTF8). It is typically used by MARC::Charset, so you 
probably don't need to use this yourself. 

=head1 METHODS

=cut 

use strict;
use constant CHAR_SIZE	    => 1;
my %marc2unicode;

=head1 

The constructor, which will return you a MARC::Charset::GreekSymbols object.

=cut


sub new {
    my $class = shift;
    return bless {}, ref($class) || $class;
}

=head1 name()

Returns the name of the character set.

=cut


sub name {
    return('Greek-Symbols');
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
    return(undef); ## aren't any
}

=head1 getCharSize()

Returns the number of bytes in each character of this character set.

=cut


sub getCharSize {
    return(CHAR_SIZE);
}

%marc2unicode = (

chr(0x61)=>chr(0x03B1),  #GREEK SMALL LETTER ALPHA
chr(0x62)=>chr(0x03B2),  #GREEK SMALL LETTER BETA
chr(0x63)=>chr(0x03B3),  #GREEK SMALL LETTER GAMMA

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
