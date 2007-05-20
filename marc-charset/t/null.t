use strict;
use warnings;
use Test::More tests => 1;

use MARC::Charset qw(marc8_to_utf8);

my @bytes = qw(EB 70 EC 75);
my $marc8 = '';
map {$marc8 .= chr(hex($_))} @bytes;

my $utf8 = marc8_to_utf8($marc8);
unlike $utf8, qr/\x00/, 'no nulls'
