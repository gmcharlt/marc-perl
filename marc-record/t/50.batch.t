#!/usr/bin/perl -w

use strict;
use integer;

use Test::More tests=>6;

BEGIN {
    use_ok( 'MARC::Batch' );
}



# Test the USMARC stuff
USMARC: {
    my $batch = new MARC::Batch( 'MARC::File::USMARC', 't/camel.usmarc' );
    isa_ok( $batch, 'MARC::Batch', 'MARC batch' );

    my $n = 0;
    while ( my $marc = $batch->next() ) {
	++$n;
    }
    is( $n, 10, 'Got 10 USMARC records' );
}

# Test MicroLIF batch

MicroLIF: {
    my @files = <t/sample*.lif>;
    is( scalar @files, 2, 'Only have 2 sample*.lif files' );

    my $batch = new MARC::Batch( 'MicroLIF', @files );
    isa_ok( $batch, 'MARC::Batch', 'MicroLIF batch' );

    my $n = 0;
    while ( my $marc = $batch->next() ) {
	++$n;
    }
    is( $n, 120, 'Got 120 LIF records' );
}
