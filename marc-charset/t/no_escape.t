use Test::More qw(no_plan);
use strict;
use warnings;

use MARC::Charset qw(marc8_to_utf8);
is('foobar', marc8_to_utf8('foobar'), 'no escapes');
