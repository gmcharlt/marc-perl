# $Id: 00.load.t,v 1.3 2003/02/25 20:41:52 petdance Exp $

use strict;

use Test::More tests=>2;

BEGIN {
    use_ok( 'MARC::Record' );
    use_ok( 'MARC::Batch' );
}
