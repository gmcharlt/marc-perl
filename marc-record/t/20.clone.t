# clone.t - Test creating a MARC record for the Camel book
#
# Bugs, comments, suggestions welcome: marc@petdance.com

use strict;
use integer;

use Test::More tests=>6;

BEGIN {
    use_ok( 'MARC::File::USMARC' );
}

my $file = MARC::File::USMARC->in( 't/camel.usmarc' );
isa_ok( $file, 'MARC::File::USMARC', 'USMARC input file object' );
my $marc = $file->next();
isa_ok( $marc, 'MARC::Record', 'Read from file' );
$file->close;

my $clone = $marc->clone;
isa_ok( $clone, 'MARC::Record', 'Cloned record' );

ok( $marc != $clone,		'Clone and original are different' );

ok( $marc->as_formatted eq $clone->as_formatted,
				'Clone and original match content' );
