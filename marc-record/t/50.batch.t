# $Id: 50.batch.t,v 1.11 2004/05/23 23:08:35 edsummers Exp $

use strict;
use integer;

use Test::More tests=>268;

BEGIN: {
    use_ok( 'MARC::Batch' );
}

# Test the USMARC stuff
USMARC: {
    my $batch = new MARC::Batch( 'USMARC', 't/camel.usmarc' );
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
    my @files = <t/sample*.lif>;
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
