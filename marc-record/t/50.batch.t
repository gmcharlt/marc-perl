#!perl -Tw

use strict;
use integer;
use File::Spec;

use Test::More tests=>268;

BEGIN: {
    use_ok( 'MARC::Batch' );
}

# Test the USMARC stuff
USMARC: {

    my $filename = File::Spec->catfile( File::Spec->updir(), 't', 'camel.usmarc' );
    my $batch = new MARC::Batch( 'USMARC', $filename );
    isa_ok( $batch, 'MARC::Batch', 'MARC batch' );

    my $n = 0;
    while ( my $marc = $batch->next() ) {
	isa_ok( $marc, 'MARC::Record' );

	my $f245 = $marc->field( '245' );
	isa_ok( $f245, 'MARC::Field' );
	++$n;
    }
    is( $n, 10, 'Got 10 USMARC records' );
}

# Test MicroLIF batch

MicroLIF: {

    my $filepath = File::Spec->catdir( File::Spec->updir(), 't' );
    opendir(TESTDIR, $filepath) || die "can't opendir $filepath: $!";
    my @files = grep { /sample.*\.lif/ && -f $filepath.$_ } readdir(TESTDIR);
    closedir TESTDIR;
    is( scalar @files, 3, 'Only have 3 sample*.lif files' );

    my $batch = new MARC::Batch( 'MicroLIF', @files );
    isa_ok( $batch, 'MARC::Batch', 'MicroLIF batch' );

    my $n = 0;
    while ( my $marc = $batch->next() ) {
	isa_ok( $marc, 'MARC::Record' );

	my $f245 = $marc->field( '245' );
	isa_ok( $f245, 'MARC::Field' );
	++$n;
    }
    is( $n, 121, 'Got 120 LIF records' );
}
