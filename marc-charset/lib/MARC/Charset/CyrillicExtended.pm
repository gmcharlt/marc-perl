package MARC::Charset::CyrillicExtended;

use MARC::Charset::Generic qw( :all );
use base qw( MARC::Charset::Generic );

=head1 NAME

MARC::Charset::CyrillicExtended - MARC8/UTF8 mappings for Extended Cyrillic

=head1 SYNOPSIS

 use MARC::Charset::CyrillicExtended;
 my $cs = MARC::Charset::CyrillicExtended->new();

=head1 DESCRIPTION

MARC::Charset::CyrillicExtented provides a mapping between the MARC8 Extended
Cyrillic character set and Unicode(UTF8). It is typically used by 
MARC::Charset, so you probably don't need to use this yourself. It inherits from
MARC::Charset::Generic, so you'll need to look at those docs to see all of the 
methods you can call.

=head1 METHODS

=cut 

use strict;
our %marc2unicode;

=head1 

The constructor, which will return you a MARC::Charset::CyrillicExtended object.

=cut


sub new {
    my $class = shift;
    return bless 
	{
	    NAME	=> 'Cyrillic-Extended',
	    CHARSETCODE	=> EXTENDED_CYRILLIC,
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
    return(undef); ## aren't any
}

%marc2unicode = (
    
chr(0xC0)=>chr(0x0491), #LOWER GE WITH UPTURN / CYR SM LETTER GHE WITH UPTURN
chr(0xC1)=>chr(0x0452), #LOWERCASE DJE / CYRILLIC SMALL LETTER DJE (Serbian)
chr(0xC2)=>chr(0x0453), #CYRILLIC SMALL LETTER GJE
chr(0xC3)=>chr(0x0454), #LOWERCASE E / CYRILLIC SMALL LETTER UKRAINIAN IE
chr(0xC4)=>chr(0x0451), #CYRILLIC SMALL LETTER IO
chr(0xC5)=>chr(0x0455), #CYRILLIC SMALL LETTER DZE
chr(0xC6)=>chr(0x0456), #LOWERCASE I / CYR SM LETTER BYELORUSSIAN-UKRANIAN I
chr(0xC7)=>chr(0x0457), #LOWERCASE YI / CYRILLIC SMALL LETTER YI (Ukrainian)
chr(0xC8)=>chr(0x0458), #CYRILLIC SMALL LETTER JE
chr(0xC9)=>chr(0x0459), #CYRILLIC SMALL LETTER LJE
chr(0xCA)=>chr(0x045A), #CYRILLIC SMALL LETTER NJE
chr(0xCB)=>chr(0x045B), #LOWERCASE TSHE / CYRILLIC SMALL LETTER TSHE (Serbian)
chr(0xCC)=>chr(0x045C), #CYRILLIC SMALL LETTER KJE
chr(0xCD)=>chr(0x045E), #LOWER SHORT U / CYR SM LETTER SHORT U (Byelorussian)
chr(0xCE)=>chr(0x045F), #CYRILLIC SMALL LETTER DZHE
chr(0xD0)=>chr(0x0463), #CYRILLIC SMALL LETTER YAT
chr(0xD1)=>chr(0x0473), #CYRILLIC SMALL LETTER FITA
chr(0xD2)=>chr(0x0475), #CYRILLIC SMALL LETTER IZHITSA
chr(0xD3)=>chr(0x046B), #CYRILLIC SMALL LETTER BIG YUS
chr(0xDB)=>chr(0x005B), #OPENING SQUARE BRACKET / LEFT SQUARE BRACKET
chr(0xDD)=>chr(0x005D), #CLOSING SQUARE BRACKET / RIGHT SQUARE BRACKET
chr(0xDF)=>chr(0x005F), #SPACING UNDERSCORE / LOW LINE
chr(0xE0)=>chr(0x0490), #UPPER GE WITH UPTURN / CYR CAP LETTER GHE WITH UPTURN
chr(0xE1)=>chr(0x0402), #UPPERCASE DJE / CYRILLIC CAPITAL LETTER DJE (Serbian)
chr(0xE2)=>chr(0x0403), #CYRILLIC CAPITAL LETTER GJE
chr(0xE3)=>chr(0x0404), #UPPERCASE E / CYRILLIC CAPITAL LETTER UKRAINIAN IE
chr(0xE4)=>chr(0x0401), #CYRILLIC CAPITAL LETTER IO
chr(0xE5)=>chr(0x0405), #CYRILLIC CAPITAL LETTER DZE
chr(0xE6)=>chr(0x0406), #UPPER I / CYR CAPITAL LETTER BYELORUSSIAN-UKRANIAN I
chr(0xE7)=>chr(0x0407), #UPPERCASE YI / CYRILLIC CAPITAL LETTER YI (Ukrainian)
chr(0xE8)=>chr(0x0408), #CYRILLIC CAPITAL LETTER JE
chr(0xE9)=>chr(0x0409), #CYRILLIC CAPITAL LETTER LJE
chr(0xEA)=>chr(0x040A), #CYRILLIC CAPITAL LETTER NJE
chr(0xEB)=>chr(0x040B), #UPPERCASE TSHE / CYRILLIC CAPITAL LETTER TSHE (Serbian)
chr(0xEC)=>chr(0x040C), #CYRILLIC CAPITAL LETTER KJE
chr(0xED)=>chr(0x040E), #UPPER SHORT U / CYR CAP LETT SHORT U (Byelorussian)
chr(0xEE)=>chr(0x040F), #CYRILLIC CAPITAL LETTER DZHE
chr(0xEF)=>chr(0x042A), #CYRILLIC CAPITAL LETTER HARD SIGN
chr(0xF0)=>chr(0x0462), #CYRILLIC CAPITAL LETTER YAT
chr(0xF1)=>chr(0x0472), #CYRILLIC CAPITAL LETTER FITA
chr(0xF2)=>chr(0x0474), #CYRILLIC CAPITAL LETTER IZHITSA
chr(0xF3)=>chr(0x046A), #CYRILLIC CAPITAL LETTER BIG YUS

);

=head1 TODO

=over 4 

=item Nothing.

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
