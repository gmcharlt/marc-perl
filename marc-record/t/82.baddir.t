use strict;
use warnings;
use Test::More tests => 3;
use MARC::File::USMARC;

my $file = MARC::File::USMARC->in( 't/baddir.usmarc' );
isa_ok( $file, 'MARC::File::USMARC' );

my $r = $file->next(); 
my @warnings = $r->warnings();

is( $warnings[0], 'No directory found in record 1', 
    'got bad directory warning' );
is( $r->title(), 'Green Eggs and Ham', 
    'found title despite bad directory' );

