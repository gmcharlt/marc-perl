use Test::More tests => 3;

## this test will exercise the first type of character escapes 
## as documents at http://lcweb.loc.gov/marc/specifications/speccharmarc8.html
## Technique 1: Greek Symbols, Subscript, and Superscript Characters

use MARC::Charset qw(:all);

my $cs = MARC::Charset->new();


## Greek Symbols

my $test = 
    'it is all greek ' . 
    ESCAPE . GREEK_SYMBOLS .		    ## escape to Greek Symbols
    chr(0x61) . chr(0x62) . chr(0x63) .	    ## ALPHA BETA GAMMA
    ESCAPE . ASCII_DEFAULT.		    ## back to ASCII
    ' to me';

my $expected = 
    'it is all greek ' .
    chr(0x03B1) . chr(0x03B2) . chr(0x03B3) .
    ' to me';

is( $cs->to_utf8($test), $expected, 'Greek Symbols' );


## Subscripts

$test = 
    'subscript1' .		    
    ESCAPE . SUBSCRIPTS .		    ## escape to Subscripts 
    chr(0x31) . 			    ## subscript 1
    ESCAPE . ASCII_DEFAULT .		    ## back to ASCII
    'subscript9' .	    
    ESCAPE . SUBSCRIPTS .		    ## escape to Subscripts
    chr(0x39) .				    ## subscript 9
    ESCAPE . ASCII_DEFAULT .		    ## back to ASCII
    'subscript10' . 
    ESCAPE . SUBSCRIPTS .		    ## back to Subscripts again
    chr(0x31) . chr(0x30) .		    ## subscript 10
    ESCAPE . ASCII_DEFAULT;		    ## back to ASCII

$expected = 
    'subscript1' . chr(0x2081) . 
    'subscript9' . chr(0x2089) . 
    'subscript10' . chr(0x2081) . chr(0x2080); 

is( $cs->to_utf8($test), $expected, 'Subscripts' );


## Superscripts

$test =
    'superscript1' . 
    ESCAPE . SUPERSCRIPTS .		    ## escape to Superscripts
    chr(0x31) .				    ## superscript 1
    ESCAPE . ASCII_DEFAULT .		    ## back to ASCII
    'superscript9' . 
    ESCAPE . SUPERSCRIPTS .		    ## escape to Superscripts
    chr(0x39) .				    ## superscript 9
    ESCAPE . ASCII_DEFAULT .		    ## back to ASCII
    'superscript10' .
    ESCAPE . SUPERSCRIPTS . 
    chr(0x31) . chr(0x30) .		    ## superscript 10
    ESCAPE . ASCII_DEFAULT; 		    ## back to ASCII

$expected = 
    'superscript1' . chr(0x00B9) . 
    'superscript9' . chr(0x2079) . 
    'superscript10' . chr(0x00B9) . chr(0x2070); 

is( $cs->to_utf8($test), $expected, 'Superscripts' );
    
