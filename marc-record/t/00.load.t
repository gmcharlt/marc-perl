# $Id: 00.load.t,v 1.5 2004/03/09 23:25:18 petdance Exp $

use strict;

use Test::More tests=>7;

BEGIN {
    use_ok( 'MARC::Record' );
    use_ok( 'MARC::Batch' );
    use_ok( 'MARC::Lint' );
    use_ok( 'MARC::Field' );
    use_ok( 'MARC::File' );
    use_ok( 'MARC::File::MicroLIF' );
    use_ok( 'MARC::File::USMARC' );
}

diag( "Testing MARC::Record $MARC::Record::VERSION" );
