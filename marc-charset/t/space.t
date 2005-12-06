use Test::More tests => 3;
use strict;
use warnings;

use MARC::Charset 'marc8_to_utf8';
use MARC::Charset::Constants ':all';

is('foo bar', marc8_to_utf8('foo bar'), 'one space');
is('foo  bar', marc8_to_utf8('foo  bar'), 'two spaces');

my $test = 
    'a   ' . 
    ESCAPE . SINGLE_G0_A . BASIC_GREEK . 
    chr(0x49) .
    ESCAPE . SINGLE_G0_A . BASIC_LATIN . 
    '   b';

my $expected = 'a   ' . chr(0x0396) . '   b';
is(marc8_to_utf8($test), $expected, 'spacing with escape');


