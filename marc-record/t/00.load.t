# $Id: 00.load.t,v 1.2 2002/08/25 21:27:59 petdance Exp $

use strict;
eval 'use warnings' if $] >= 5.006;

use Test::More tests=>2;

BEGIN {
    use_ok( 'MARC::Record' );
    use_ok( 'MARC::Batch' );
}
