# $Id: 00.version.t,v 1.5 2002/08/25 21:27:59 petdance Exp $

use Test::More tests=>13;
use strict;
eval 'use warnings' if $] >= 5.006;

BEGIN {
    use_ok( $_ ) for qw( 
	MARC::Field
	MARC::Record
	MARC::File
	MARC::File::USMARC
	MARC::File::MicroLIF
	MARC::Batch
	MARC::Lint
    );
}

is( $MARC::Record::VERSION, $MARC::Field::VERSION,	    'Field matches' );
is( $MARC::Record::VERSION, $MARC::Batch::VERSION,	    'Batch matches' );
is( $MARC::Record::VERSION, $MARC::File::VERSION,	    'File matches' );
is( $MARC::Record::VERSION, $MARC::File::USMARC::VERSION,   'File::USMARC matches' );
is( $MARC::Record::VERSION, $MARC::File::MicroLIF::VERSION, 'File::MicroLIF matches' );
is( $MARC::Record::VERSION, $MARC::Lint::VERSION,	    'Lint matches' );
