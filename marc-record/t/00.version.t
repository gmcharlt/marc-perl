# $Id: 00.version.t,v 1.2 2002/04/01 03:56:00 petdance Exp $

use Test::More tests=>7;

BEGIN {
    use_ok( $_, "Loaded $_" ) for qw( MARC::Field MARC::Record MARC::Lint MARC::Batch );
}

is( $MARC::Record::VERSION, $MARC::Field::VERSION, 'Field matches' );
is( $MARC::Record::VERSION, $MARC::Batch::VERSION, 'Batch matches' );
is( $MARC::Record::VERSION, $MARC::Lint::VERSION,  'Lint matches' );
