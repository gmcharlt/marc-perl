# $Id: 00.load.t,v 1.4 2003/11/27 03:59:25 petdance Exp $

use strict;

use Test::More tests=>2;

BEGIN {
    use_ok( 'MARC::Record' );
    use_ok( 'MARC::Batch' );
}

diag( "Testing MARC::Record $MARC::Record::VERSION" );
