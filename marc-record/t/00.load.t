# $Id: 00.load.t,v 1.1 2002/03/15 22:04:22 petdance Exp $

BEGIN { $| = 1; print "1..1\n"; }
END   { print "not ok 1\n" unless $loaded; }

use MARC::Record;

$loaded = 1;
print "ok\n";

