use Test::More tests=>92;
use strict;
use MARC::Charset;

## Test Ansel character set:

my $cs = MARC::Charset->new( DIAGNOSTICS => 1 );

my %valid = (

chr(0xA1)=>chr(0x0141), 
chr(0xA2)=>chr(0x00D8), 
chr(0xA3)=>chr(0x0110), 
chr(0xA4)=>chr(0x00DE), 
chr(0xA5)=>chr(0x00C6), 
chr(0xA6)=>chr(0x0152), 
chr(0xA7)=>chr(0x02B9), 
chr(0xA8)=>chr(0x00B7), 
chr(0xA9)=>chr(0x266D), 
chr(0xAA)=>chr(0x00AE), 
chr(0xAB)=>chr(0x00B1), 
chr(0xAC)=>chr(0x01A0), 
chr(0xAD)=>chr(0x01AF), 
chr(0xAE)=>chr(0x02BE), 
chr(0xB0)=>chr(0x02BB), 
chr(0xB1)=>chr(0x0142), 
chr(0xB2)=>chr(0x00F8), 
chr(0xB3)=>chr(0x0111), 
chr(0xB4)=>chr(0x00FE), 
chr(0xB5)=>chr(0x00E6), 
chr(0xB6)=>chr(0x0153), 
chr(0xB7)=>chr(0x02BA), 
chr(0xB8)=>chr(0x0131), 
chr(0xB9)=>chr(0x00A3), 
chr(0xBA)=>chr(0x00F0), 
chr(0xBC)=>chr(0x01A1), 
chr(0xBD)=>chr(0x01B0), 
chr(0xC0)=>chr(0x00B0), 
chr(0xC1)=>chr(0x2113), 
chr(0xC2)=>chr(0x2117), 
chr(0xC3)=>chr(0x00A9), 
chr(0xC4)=>chr(0x266F), 
chr(0xC5)=>chr(0x00BF), 
chr(0xC6)=>chr(0x00A1), 
chr(0xE0)=>chr(0x0309), 
chr(0xE1)=>chr(0x0300), 
chr(0xE2)=>chr(0x0301), 
chr(0xE3)=>chr(0x0302), 
chr(0xE4)=>chr(0x0303), 
chr(0xE5)=>chr(0x0304), 
chr(0xE6)=>chr(0x0306), 
chr(0xE7)=>chr(0x0307), 
chr(0xE8)=>chr(0x0308), 
chr(0xE9)=>chr(0x030C), 
chr(0xEA)=>chr(0x030A), 
chr(0xEB)=>chr(0xFE20), 
chr(0xEC)=>chr(0xFE21),
chr(0xED)=>chr(0x0315),
chr(0xEE)=>chr(0x030B), 
chr(0xEF)=>chr(0x0310), 
chr(0xF0)=>chr(0x0327), 
chr(0xF1)=>chr(0x0328), 
chr(0xF2)=>chr(0x0323), 
chr(0xF3)=>chr(0x0324), 
chr(0xF4)=>chr(0x0325), 
chr(0xF5)=>chr(0x0333), 
chr(0xF6)=>chr(0x0332), 
chr(0xF7)=>chr(0x0326), 
chr(0xF8)=>chr(0x031C), 
chr(0xF9)=>chr(0x032E), 
chr(0xFA)=>chr(0xFE22),
chr(0xFB)=>chr(0xFE23),
chr(0xFE)=>chr(0x0313),

);

my %combining = (

chr(0xE0) => 1, 
chr(0xE1) => 1, 
chr(0xE2) => 1, 
chr(0xE3) => 1, 
chr(0xE4) => 1, 
chr(0xE5) => 1, 
chr(0xE6) => 1, 
chr(0xE7) => 1, 
chr(0xE8) => 1, 
chr(0xE9) => 1, 
chr(0xEA) => 1, 
chr(0xEB) => 1, 
chr(0xEC) => 1, 
chr(0xED) => 1, 
chr(0xEE) => 1, 
chr(0xEF) => 1, 
chr(0xF0) => 1, 
chr(0xF1) => 1, 
chr(0xF2) => 1, 
chr(0xF3) => 1, 
chr(0xF4) => 1, 
chr(0xF5) => 1, 
chr(0xF6) => 1, 
chr(0xF7) => 1, 
chr(0xF8) => 1, 
chr(0xF9) => 1, 
chr(0xFA) => 1,
chr(0xFB) => 1,
chr(0xFE) => 1, 

);

1;

## verify Ansel => Unicode mappings

foreach my $marc8 (keys(%valid)) {
    is($cs->to_utf8($marc8),$valid{$marc8},'valid Ansel');
}

## verify that combining characters work as expected
## NOTE: MARC-8 combining chars preceed the character they modify
## and Unicode combining characters follow the character they modify

for ( my $hex = 0xE0; $hex <= 0xFB; $hex=$hex+2 ) {

    ## a single combining character

    is(
	$cs->to_utf8( chr($hex) . 'o' ) => 
	'o' . $valid{ chr($hex) },
	'single combining character '.sprintf("0x%2x",$hex)
    );

    ## multiple combining characters
    
    is(
	$cs->to_utf8( chr($hex) . chr($hex+1) . 'o' ) =>
	'o' . $valid{ chr($hex) } . $valid{ chr($hex+1) },
	'multiple combining characters '.sprintf("0x%2x 0x%2x",$hex,$hex+1)
    );

}

## and check a full string

## "c'est la vie" with combining cedilla on the 'c' 
## and acute accent on the 'a' in la 
## followed by a british pound sign

my $string = chr(0xF0) . q(c'est l) . chr(0xE2) . 'a vie' . chr(0xB9);
my $expected = 'c'.chr(0x0327).q('est la).chr(0x0301).' vie'.chr(0x00A3);

is ( $cs->to_utf8($string) => $expected, 'string conversion');

	




