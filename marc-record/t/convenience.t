# $Id: convenience.t,v 1.1 2003/01/28 21:14:33 petdance Exp $

use strict;
use integer;
use Data::Dumper;
eval 'use warnings' if $] >= 5.006;

use constant CAMEL_RECORD => 8;

use Test::More tests=>( 7 + CAMEL_RECORD );

BEGIN {
    use_ok( 'MARC::File::USMARC' );
}

my $file = MARC::File::USMARC->in( 't/camel.usmarc' );
isa_ok( $file, 'MARC::File::USMARC', 'USMARC file' );

my $marc;
for ( 1..8 ) { # Skip to the camel
    $marc = $file->next();
    isa_ok( $marc, 'MARC::Record', 'Got a record' );
}
$file->close;

is( $marc->author,		'Wall, Larry.' );
is( $marc->title,		'Programming Perl / Larry Wall, Tom Christiansen & Jon Orwant.' );
is( $marc->title_proper,	'Programming Perl /' );
is( $marc->edition,		'3rd ed.' );
is( $marc->publication_date,	'2000.' );
