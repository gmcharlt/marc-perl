use Test::More tests => 36;
use strict;
use MARC::Charset;
my $cs = MARC::Charset->new();

## see if we can use valid control characters

my %valid = (
    chr(0x1B)=>chr(0x001B), # ESCAPE
    chr(0x1F)=>chr(0x001F), # SUBFIELD DELIMITER
    chr(0x1E)=>chr(0x001E), # FIELD TERMINATOR
    chr(0x1D)=>chr(0x001D), # RECORD TERMINATOR
    chr(0x20)=>chr(0x0020), # SPACE
    chr(0x88)=>chr(0x0098), # NON-SORT BEGIN / START OF STRING
    chr(0x89)=>chr(0x009C), # NON-SORT END / STRING TERMINATOR
    chr(0x8D)=>chr(0x200D), # JOINER / ZERO WIDTH JOINER
    chr(0x8E)=>chr(0x200C), # NON-JOINER / ZERO WIDTH NON-JOINER
);


while ( my($test,$expected) = each %valid ) {
    my $converted = $cs->to_utf8($test);
    is( $converted => $expected,
	'valid control character chr(0x'.sprintf("%2x",ord($test)).')'
    ); 
}

## make sure we do not allow other control characters

foreach my $hex ( 0x00 .. 0x1A ) {
    my $converted = $cs->to_utf8(chr($hex));
    is ($converted => '',
	'correctly suppressed chr(0x'.sprintf("%2x",$hex).')'
    );
}
	    




