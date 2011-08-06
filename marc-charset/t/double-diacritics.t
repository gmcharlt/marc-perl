use strict; use warnings;

BEGIN {
    binmode STDERR, ':utf8';
}

use MARC::Charset qw/marc8_to_utf8/;
use Test::More tests => 2;

use utf8;

my $marc8     = "Ha\xFAn\xFBgin Il\xEBi\xECushin";
my $expected  = 'Han͠gin Ili͡ushin';
my $incorrect = 'Han͠g︣in Ili͡u︡shin';

my $utf8 = marc8_to_utf8($marc8);

is($utf8, $expected,   'successful conversion of double diacritics');
if ($utf8 eq $incorrect) {
    fail('not doing old, incorrect double diacritic conversion');
} else {
    pass('not doing old, incorrect double diacritic conversion');
};
