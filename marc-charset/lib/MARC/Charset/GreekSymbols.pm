package MARC::Charset::GreekSymbols;

use MARC::Charset::Generic qw( :all );
use base qw( MARC::Charset::Generic );

=head1 NAME

MARC::Charset::GreekSymbols - MARC8/UTF8 character encodings for Greek Symbols

=head1 SYNOPSIS

 use MARC::Charset::GreekSymbols;
 my $cs = MARC::Charset::GreekSymbols->new();

=head1 DESCRIPTION

MARC::Charset::GreekSymbols provides a mapping between the MARC8 Greek Symbol 
character set and Unicode(UTF8). It is typically used by MARC::Charset, so you 
probably don't need to use this yourself. It inherits from
MARC::Charset::Generic, so look at those docs to see all the available methods.

=head1 METHODS

=cut 

use strict;
our %marc2unicode;

=head1 

The constructor, which will return you a MARC::Charset::GreekSymbols object.

=cut


sub new {
    my $class = shift;
    return bless 
	{
	    NAME	=> 'Greek-Symbols',
	    CHARSETCODE	=> GREEK_SYMBOLS,
	    CHARSIZE	=> 1,

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
    return(undef); ## aren't any
}

%marc2unicode = (

chr(0x61)=>chr(0x03B1),  #GREEK SMALL LETTER ALPHA
chr(0x62)=>chr(0x03B2),  #GREEK SMALL LETTER BETA
chr(0x63)=>chr(0x03B3),  #GREEK SMALL LETTER GAMMA

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
