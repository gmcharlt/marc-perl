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
ok( defined $file,  'Created $file object' );
my $marc = $file->next();
ok( defined $marc,  'Read from file' );
$file->close;

my $clone = $marc->clone;
ok( defined $clone,		'Cloned record' );

ok( $marc != $clone,		'Clone and original are different' );

ok( $marc->as_formatted eq $clone->as_formatted,
				'Clone and original match content' );

use Data::Dumper;
#diag( $marc->as_formatted );
#diag( $clone->as_formatted );
