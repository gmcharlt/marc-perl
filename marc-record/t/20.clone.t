# clone.t - Test creating a MARC record for the Camel book
#
# Bugs, comments, suggestions welcome: marc@petdance.com

use strict;
use integer;

use MARC::Record;
use Test::More tests=>5;

pass( 'Loaded modules' );

# Test 1: Testing as_usmarc()
my $filename = 't/camel.usmarc';
open( my $fh, $filename ) or die "Can't open $filename: $!";
my $marc = MARC::Record::next_from_file( $fh );
ok( defined $marc,		'Read from file' );
close $fh;

my $clone = $marc->clone;
ok( defined $clone,		'Cloned record' );

ok( $marc != $clone,		'Clone and original are different' );

ok( $marc->as_formatted eq $clone->as_formatted,
				'Clone and original match content' );

use Data::Dumper;
#diag( $marc->as_formatted );
#diag( $clone->as_formatted );
