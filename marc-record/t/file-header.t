# $Id: file-header.t,v 1.1 2003/03/12 20:15:56 moregan Exp $

use strict;
use integer;

use Test::More tests=>5;

BEGIN {
    use_ok( 'MARC::File::MicroLIF' );
}


MISSINGHEADER: {
    my $file = MARC::File::MicroLIF->in( 't/sample1.lif' );
    isa_ok( $file, 'MARC::File::MicroLIF', 'got a MicroLIF file' );
    ok( !$file->header(), 'file contains no header' );
    $file->close();
}

MISSINGHEADER: {
    my $file = MARC::File::MicroLIF->in( 't/sample20.lif' );
    isa_ok( $file, 'MARC::File::MicroLIF', 'got a MicroLIF file' );
    is( 
	$file->header(), 
	'header 20 rec MicroLIF file                                                     ', 
	'file header correct' 
    );
    $file->close();
}

