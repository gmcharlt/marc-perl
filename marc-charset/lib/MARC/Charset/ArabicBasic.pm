package MARC::Charset::ArabicBasic;

use MARC::Charset::Generic qw( :all );
use base qw( MARC::Charset::Generic );

=head1 NAME

MARC::Charset::ArabicBasic - A MARC8/UTF8 mapping for Basic Arabic.

=head1 SYNOPSIS

 use MARC::Charset::ArabicBasic;
 my $cs = MARC::Charset::ArabicBasic->new();

=head1 DESCRIPTION

MARC::Charset::ArabicBasic provides a mapping between the MARC8 Basic Arabic 
character set and Unicode(UTF8). It is typically used by MARC::Charset, so you 
probably don't need to use this yourself. It inherits from
MARC::Charset::Generic so you will have to look at those docs to see all the
methods you can call.

=head1 METHODS

=cut 

use strict;
our %marc2unicode;

=head1 

The constructor, which will return you a MARC::Charset::ArabicBasic object.

=cut


sub new {
    my $class = shift;
    return bless 
	{
	    NAME	=> 'Arabic-Basic',
	    CHARSETCODE	=> BASIC_ARABIC,
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
    return(undef);
}

%marc2unicode = (

chr(0x21)=>chr(0x0021), #EXCLAMATION MARK
chr(0x22)=>chr(0x0022), #QUOTATION MARK
chr(0x23)=>chr(0x0023), #NUMBER SIGN
chr(0x24)=>chr(0x0024), #DOLLAR SIGN
chr(0x25)=>chr(0x066A), #PERCENT SIGN / ARABIC PERCENT SIGN
chr(0x26)=>chr(0x0026), #AMPERSAND
chr(0x27)=>chr(0x0027), #APOSTROPHE
chr(0x28)=>chr(0x0028), #OPENING PARENTHESIS / LEFT PARENTHESIS
chr(0x29)=>chr(0x0029), #CLOSING PARENTHESIS / RIGHT PARENTHESIS
chr(0x2A)=>chr(0x066D), #ASTERISK / ARABIC FIVE POINTED STAR
chr(0x2B)=>chr(0x002B), #PLUS SIGN
chr(0x2C)=>chr(0x060C), #ARABIC COMMA
chr(0x2D)=>chr(0x002D), #HYPHEN-MINUS
chr(0x2E)=>chr(0x002E), #PERIOD, DECIMAL POINT / FULL STOP
chr(0x2F)=>chr(0x002F), #SLASH / SOLIDUS
chr(0x30)=>chr(0x0660), #ARABIC-INDIC DIGIT ZERO
chr(0x31)=>chr(0x0661), #ARABIC-INDIC DIGIT ONE
chr(0x32)=>chr(0x0662), #ARABIC-INDIC DIGIT TWO
chr(0x33)=>chr(0x0663), #ARABIC-INDIC DIGIT THREE
chr(0x34)=>chr(0x0664), #ARABIC-INDIC DIGIT FOUR
chr(0x35)=>chr(0x0665), #ARABIC-INDIC DIGIT FIVE
chr(0x36)=>chr(0x0666), #ARABIC-INDIC DIGIT SIX
chr(0x37)=>chr(0x0667), #ARABIC-INDIC DIGIT SEVEN
chr(0x38)=>chr(0x0668), #ARABIC-INDIC DIGIT EIGHT
chr(0x39)=>chr(0x0669), #ARABIC-INDIC DIGIT NINE
chr(0x3A)=>chr(0x003A), #COLON
chr(0x3B)=>chr(0x061B), #ARABIC SEMICOLON
chr(0x3C)=>chr(0x003C), #LESS-THAN SIGN
chr(0x3D)=>chr(0x003D), #EQUALS SIGN
chr(0x3E)=>chr(0x003E), #GREATER-THAN SIGN
chr(0x3F)=>chr(0x061F), #ARABIC QUESTION MARK
chr(0x41)=>chr(0x0621), #HAMZAH / ARABIC LETTER HAMZA
chr(0x42)=>chr(0x0622), #ARABIC LETTER ALEF WITH MADDA ABOVE
chr(0x43)=>chr(0x0623), #ARABIC LETTER ALEF WITH HAMZA ABOVE
chr(0x44)=>chr(0x0624), #ARABIC LETTER WAW WITH HAMZA ABOVE
chr(0x45)=>chr(0x0625), #ARABIC LETTER ALEF WITH HAMZA BELOW
chr(0x46)=>chr(0x0626), #ARABIC LETTER YEH WITH HAMZA ABOVE
chr(0x47)=>chr(0x0627), #ARABIC LETTER ALEF
chr(0x48)=>chr(0x0628), #ARABIC LETTER BEH
chr(0x49)=>chr(0x0629), #ARABIC LETTER TEH MARBUTA
chr(0x4A)=>chr(0x062A), #ARABIC LETTER TEH
chr(0x4B)=>chr(0x062B), #ARABIC LETTER THEH
chr(0x4C)=>chr(0x062C), #ARABIC LETTER JEEM
chr(0x4D)=>chr(0x062D), #ARABIC LETTER HAH
chr(0x4E)=>chr(0x062E), #ARABIC LETTER KHAH
chr(0x4F)=>chr(0x062F), #ARABIC LETTER DAL
chr(0x50)=>chr(0x0630), #ARABIC LETTER THAL
chr(0x51)=>chr(0x0631), #ARABIC LETTER REH
chr(0x52)=>chr(0x0632), #ARABIC LETTER ZAIN
chr(0x53)=>chr(0x0633), #ARABIC LETTER SEEN
chr(0x54)=>chr(0x0634), #ARABIC LETTER SHEEN
chr(0x55)=>chr(0x0635), #ARABIC LETTER SAD
chr(0x56)=>chr(0x0636), #ARABIC LETTER DAD
chr(0x57)=>chr(0x0637), #ARABIC LETTER TAH
chr(0x58)=>chr(0x0638), #ARABIC LETTER ZAH
chr(0x59)=>chr(0x0639), #ARABIC LETTER AIN
chr(0x5A)=>chr(0x063A), #ARABIC LETTER GHAIN
chr(0x5B)=>chr(0x005B), #OPENING SQUARE BRACKET / LEFT SQUARE BRACKET
chr(0x5D)=>chr(0x005D), #CLOSING SQUARE BRACKET / RIGHT SQUARE BRACKET
chr(0x60)=>chr(0x0640), #ARABIC TATWEEL
chr(0x61)=>chr(0x0641), #ARABIC LETTER FEH
chr(0x62)=>chr(0x0642), #ARABIC LETTER QAF
chr(0x63)=>chr(0x0643), #ARABIC LETTER KAF
chr(0x64)=>chr(0x0644), #ARABIC LETTER LAM
chr(0x65)=>chr(0x0645), #ARABIC LETTER MEEM
chr(0x66)=>chr(0x0646), #ARABIC LETTER NOON
chr(0x67)=>chr(0x0647), #ARABIC LETTER HEH
chr(0x68)=>chr(0x0648), #ARABIC LETTER WAW
chr(0x69)=>chr(0x0649), #ARABIC LETTER ALEF MAKSURA
chr(0x6A)=>chr(0x064A), #ARABIC LETTER YEH
chr(0x6B)=>chr(0x064B), #ARABIC FATHATAN
chr(0x6C)=>chr(0x064C), #ARABIC DAMMATAN
chr(0x6D)=>chr(0x064D), #ARABIC KASRATAN
chr(0x6E)=>chr(0x064E), #ARABIC FATHA
chr(0x6F)=>chr(0x064F), #ARABIC DAMMA
chr(0x70)=>chr(0x0650), #ARABIC KASRA
chr(0x71)=>chr(0x0651), #ARABIC SHADDA
chr(0x72)=>chr(0x0652), #ARABIC SUKUN
chr(0x73)=>chr(0x0671), #ARABIC LETTER ALEF WASLA
chr(0x74)=>chr(0x0670), #ARABIC LETTER SUPERSCRIPT ALEF
chr(0x78)=>chr(0x066C), #ARABIC THOUSANDS SEPARATOR
chr(0x79)=>chr(0x201D), #RIGHT DOUBLE QUOTATION MARK
chr(0x7A)=>chr(0x201C), #LEFT DOUBLE QUOTATION MARK

);

=head1 TODO

=over 4 

=item *

Nothing

=back

=head1 SEE ALSO

=item MARC::Charset::Generic

=head1 AUTHORS

=over 4

=item Ed Summers <ehs@pobox.com>

=back

=cut


1;
