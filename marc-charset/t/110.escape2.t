use Test::More tests=>1;

## this test will exercise the first type of character escapes 
## as documents at http://lcweb.loc.gov/marc/specifications/speccharmarc8.html
## "Technique 2: Other Alternate Graphic Character Sets"

use MARC::Charset qw(:all); 
my $cs = MARC::Charset->new();

## test some greek 

$test = 
    'this is greek' .			    ## regular ASCII
    ESCAPE . SINGLE_G0_A . BASIC_GREEK .    ## escape to Greek
    chr(0x49) .				    ## zeta
    ESCAPE . SINGLE_G0_A . BASIC_LATIN .    ## back to ASCII
    'this is not';			    ## regular ASCII

$expected = 'this is greek' . chr(0x0396) . 'this is not';

is ( $cs->to_utf8($test), $expected, 'escape type 2 to Greek' );

