use strict;
use Test::More qw( no_plan );
use MARC::Charset;
use MARC::Charset::Generic qw( :all );
use MARC::Charset::CyrillicBasic;
use MARC::Charset::CyrillicExtended;

my $charset = MARC::Charset->new();


## MAKE SURE ALL THE CHARACTER SETS ARE THERE

is( 
    $charset->to_marc8( chr( 0x0041 ) ), 
    chr( 0x41),
    'ASCII'
); 

is( 
    $charset->to_marc8( chr( 0x0131 ) ),
    chr( 0xB8 ),
    'Ansel'
);

is(
    $charset->to_marc8( chr( 0x0628 ) ),
    ESCAPE . SINGLE_G0_A . BASIC_ARABIC . chr( 0x48 ) . 
	ESCAPE . ASCII_DEFAULT,
    'Basic Arabic' 
);

is(
    $charset->to_marc8( chr( 0x068D ) ),
    ESCAPE . SINGLE_G0_A . EXTENDED_ARABIC . chr( 0xB9 ) . 
	ESCAPE . ASCII_DEFAULT,
    'Extended Arabic'
);

is(
    $charset->to_marc8( chr( 0x0440 ) ),
    ESCAPE . SINGLE_G0_A . BASIC_CYRILLIC . chr( 0x52 ) . 
	ESCAPE . ASCII_DEFAULT,
    'Basic Cyrillic'
);

is( 
    $charset->to_marc8( chr( 0x0408 ) ),
    ESCAPE . SINGLE_G0_A . EXTENDED_CYRILLIC . chr( 0xE8 ) . 
	ESCAPE . ASCII_DEFAULT,
    'Extended Cyrillic'
);

is( 
    $charset->to_marc8( chr( 0x0398 ) ),
    ESCAPE . SINGLE_G0_A . BASIC_GREEK . chr( 0x4B ) . 
	ESCAPE . ASCII_DEFAULT,
    'Greek'
);

## note: we skip Greek Symbols since when mapping from utf8 to marc8
## we always use the Greek character set instead

is( 
    $charset->to_marc8( chr( 0x05E0 ) ),
    ESCAPE . SINGLE_G0_A . BASIC_HEBREW . chr( 0x70 ) . 
	ESCAPE . ASCII_DEFAULT,
    'Hebrew' 
);

is( $charset->to_marc8( chr( 0x2083 ) ),
    ESCAPE . SUBSCRIPTS . chr( 0x33 ) . ESCAPE . ASCII_DEFAULT,
    'Subscripts'
);

is( $charset->to_marc8( chr( 0x2074 ) ),
    ESCAPE . SUPERSCRIPTS . chr( 0x34 ) . ESCAPE . ASCII_DEFAULT,
    'Superscripts'
);
    
is( 
    $charset->to_marc8( chr( 0x71AC ) ),
    ESCAPE . MULTI_G0_A . CJK . chr( 0x21 ) . chr( 0x49 ) . chr( 0x7C ) . 
	ESCAPE . ASCII_DEFAULT, 
    'East Asian'
);





## COMBINING CHARACTERS

is( 
    $charset->to_marc8( 'c' . chr( 0x0327 ) . 'edilla' ),
    chr( 0xF0 ) . 'cedilla',
    'string with interior combining character'
);

is(
    $charset->to_marc8( 'abc' . chr( 0x0327 ) . chr( 0x0300 ) . chr( 0x0301 ) 
	. 'def' ),
    'ab' . chr( 0xF0 ) . chr( 0xE1 ) . chr( 0xE2 ) . 'cdef',
    'string with multiple interior combining characters'
);


## ESCAPING TO OTHER CHARACTER SETS 

is( 
    $charset->to_marc8( chr( 0x043A ) ),
    ESCAPE . SINGLE_G0_A . BASIC_CYRILLIC . chr( 0x4B ) .
	ESCAPE . ASCII_DEFAULT ,
    'CYRILLIC SMALL LETTER KA'
);


is( 
    $charset->to_marc8( chr( 0x05D0 ) . chr( 0x043B ) ),
    ESCAPE . SINGLE_G0_A . BASIC_HEBREW . chr( 0x60 ) .
	ESCAPE . SINGLE_G0_A . BASIC_CYRILLIC . chr( 0x4C ) .
	ESCAPE . ASCII_DEFAULT,
    'string with multiple character sets'
);

$charset = MARC::Charset->new(
    g0	=> MARC::Charset::CyrillicBasic->new(),
    g1	=> MARC::Charset::CyrillicExtended->new()
);

is( 
    $charset->to_marc8( chr( 0x043A ) ),
    chr( 0x4B ),
    'Non ASCII/Ansel default character sets'
);

is( 
    $charset->to_marc8( chr( 0x05D0 ) ),
    ESCAPE . SINGLE_G0_A . BASIC_HEBREW . chr( 0x60 ) .
	ESCAPE . SINGLE_G0_A . BASIC_CYRILLIC,
    'Non ASCII/Ansel escape to another character set'
);

