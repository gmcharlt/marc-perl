# test that we can pass filehandles to MARC::File::USMARC and MARC::Batch

use Test::More tests => 206;
use strict;
use IO::File;

use_ok( 'MARC::File::USMARC' );
use_ok( 'MARC::File::MicroLIF' );
use_ok( 'MARC::Batch' );

# first try globs with MARC::File::USMARC

USMARC_FILE_GLOB: { 

    open( MARCDATA, 't/camel.usmarc' );
    my $fh = *MARCDATA;
    my $file = MARC::File::USMARC->in( $fh );
    isa_ok( $file, "MARC::File::USMARC" );

    my $count = 0;
    while ( my $r = $file->next() ) {
	++$count;
	isa_ok( $r, "MARC::Record" );
    }
    is( $count, 10, 'MARC::File::USMARC avec globbed file handle works' );

}


# now try IO::File objects with MARC::File::USMARC

USMARC_IO_FILE: {

    my $fh = IO::File->new( 't/camel.usmarc' );
    isa_ok( $fh, "IO::File" );
    my $file = MARC::File::USMARC->in( $fh );
    isa_ok( $file, "MARC::File::USMARC" );

    my $count = 0;
    while ( my $r = $file->next() ) {
	++$count;
	isa_ok( $r, "MARC::Record" );
    }
    is( $count, 10, 'MARC::File::USMARC avec IO::File object works' );

}

# now try globs with MARC::File::MicroLIF

MICROLIF_FILE_GLOB: {

    open( LIFDATA, 't/sample20.lif' );
    my $fh = *LIFDATA;
    my $file = MARC::File::MicroLIF->in( $fh );
    isa_ok( $file, "MARC::File::MicroLIF" );

    my $count = 0;
    while ( my $r = $file->next() ) {
	++$count;
	isa_ok( $r, "MARC::Record" );
    }
    is( $count, 20, 'MARC::File::MicroLIF avec globbed file handle works' );

}

# and IO::File object with MARC::File::MicroLIF

MICROLIF_IO_FILE: {

    my $fh = IO::File->new( 't/sample20.lif' );
    isa_ok( $fh, "IO::File" );
    my $file = MARC::File::MicroLIF->in( $fh );
    isa_ok( $file, "MARC::File::MicroLIF" );

    my $count = 0;
    while ( my $r = $file->next() ) {
	++$count;
	isa_ok( $r, "MARC::Record" );
    }
    is( $count, 20, 'MARC::File::MicroLIF avec IO::File object works' );

}

# ok now lets check that MARC::Batch works as expected 

MARC_BATCH_FILEHANDLE: {

    my $fh = IO::File->new( 't/camel.usmarc' );
    isa_ok( $fh, "IO::File" );
    my $batch = MARC::Batch->new( 'USMARC', $fh );
    isa_ok( $batch, "MARC::Batch" );

    my $count = 0;
    while ( my $r = $batch->next() ) {
	++$count;
	isa_ok( $r, "MARC::Record" );
    }
    is( $count, 10, 'MARC::Batch avec IO::File object and USMARC' );

}

# now lets try two filehandles

MARC_BATCH_FILEHANDLES: {

    my $fh1 = IO::File->new( 't/camel.usmarc' );
    isa_ok( $fh1, "IO::File" );
    my $fh2 = IO::File->new( 't/camel.usmarc' );
    isa_ok( $fh2, "IO::File" );
    my $batch = MARC::Batch->new( 'USMARC', $fh1, $fh2 );
    isa_ok( $batch, "MARC::Batch" );

    my $count = 0;
    while ( my $r = $batch->next() ) {
	++$count;
	isa_ok( $r, "MARC::Record" );
    }
    is( $count, 20, 'MARC::Batch avec IO::File objects and USMARC' );

}

# now lets try a mix of filenames, IO::File objects and globs

MARC_BATCH_MIX: {

    open( MARCDATA, 't/camel.usmarc' );
    my $fh1 = *MARCDATA;
    my $fh2 = IO::File->new( 't/camel.usmarc' );
    isa_ok( $fh2, "IO::File" );
    my $batch = MARC::Batch->new( 'USMARC', $fh1, $fh2, 't/camel.usmarc' );
    isa_ok( $batch, "MARC::Batch" );

    my $count = 0;
    while ( my $r = $batch->next() ) {
	++$count;
	isa_ok( $r, "MARC::Record" );
    }
    is( $count, 30, 'MARC::Batch avec mixture of handles and names and Lif');

}

MICROLIF_BATCH_MIX: {

    open( LIFDATA, 't/sample20.lif' );
    my $fh1 = *LIFDATA;
    my $fh2 = IO::File->new( 't/sample20.lif' );
    isa_ok( $fh2, "IO::File" );
    my $batch = MARC::Batch->new( 'MicroLIF', $fh1, $fh2, 't/sample20.lif' );
    isa_ok( $batch, "MARC::Batch" );

    my $count = 0;
    while ( my $r = $batch->next() ) {
	++$count;
	isa_ok( $r, "MARC::Record" );
    }
    is( $count, 60, 'MARC::Batch avec mixture of handles and names and Lif' );

}
