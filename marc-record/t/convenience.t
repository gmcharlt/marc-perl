# $Id: convenience.t,v 1.3 2003/01/28 21:40:57 petdance Exp $

use strict;
use integer;
eval 'use warnings' if $] >= 5.006;

use constant PERLCONF_SKIPS => 6;
use constant CAMEL_SKIPS => 2;
use constant XPLATFORM_SKIPS => 2;

use Test::More tests=>( 2 + (5*3) + CAMEL_SKIPS + PERLCONF_SKIPS + XPLATFORM_SKIPS );

BEGIN {
    use_ok( 'MARC::File::USMARC' );
}

my $file = MARC::File::USMARC->in( 't/camel.usmarc' );
isa_ok( $file, 'MARC::File::USMARC', 'USMARC file' );

my $marc;
for ( 1..PERLCONF_SKIPS ) { # Skip to the Perl conference
    $marc = $file->next();
    isa_ok( $marc, 'MARC::Record', 'Got a record' );
}

is( $marc->author,		'Perl Conference 4.0 (2000 : Monterey, Calif.)' );
is( $marc->title,		'Proceedings of the Perl Conference 4.0 : July 17-20, 2000, Monterey, California.' );
is( $marc->title_proper,	'Proceedings of the Perl Conference 4.0 :' );
is( $marc->edition,		'1st ed.' );
is( $marc->publication_date,	'2000.' );

for ( 1..CAMEL_SKIPS ) { # Skip to the camel
    $marc = $file->next();
    isa_ok( $marc, 'MARC::Record', 'Got a record' );
}

is( $marc->author,		'Wall, Larry.' );
is( $marc->title,		'Programming Perl / Larry Wall, Tom Christiansen & Jon Orwant.' );
is( $marc->title_proper,	'Programming Perl /' );
is( $marc->edition,		'3rd ed.' );
is( $marc->publication_date,	'2000.' );

for ( 1..XPLATFORM_SKIPS ) { # Skip to Cross-Platform Perl
    $marc = $file->next();
    isa_ok( $marc, 'MARC::Record', 'Got a record' );
}

is( $marc->author,		'Foster-Johnson, Eric.' );
is( $marc->title,		'Cross-platform Perl / Eric F. Johnson.' );
is( $marc->title_proper,	'Cross-platform Perl /' );
is( $marc->edition,		'' );
is( $marc->publication_date,	'2000.' );

$file->close;

