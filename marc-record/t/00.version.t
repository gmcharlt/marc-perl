# $Id: 00.version.t,v 1.4 2002/04/02 14:08:39 petdance Exp $

use Test::More tests=>13;

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
