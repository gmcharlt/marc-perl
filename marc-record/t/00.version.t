# $Id: 00.version.t,v 1.3 2002/04/01 20:22:40 petdance Exp $

use Test::More tests=>11;

BEGIN {
    use_ok( $_ ) for qw( MARC::Field MARC::Record MARC::Lint MARC::File MARC::File::USMARC MARC::Batch );
}

is( $MARC::Record::VERSION, $MARC::Field::VERSION, 'Field matches' );
is( $MARC::Record::VERSION, $MARC::Batch::VERSION, 'Batch matches' );
is( $MARC::Record::VERSION, $MARC::Lint::VERSION,  'Lint matches' );
is( $MARC::Record::VERSION, $MARC::File::VERSION,  'File matches' );
is( $MARC::Record::VERSION, $MARC::File::USMARC::VERSION,  'File::USMARC matches' );
