#!perl -Tw

use Test::More tests => 8;

use strict;
use MARC::Record;
use MARC::File::USMARC;
use Encode;
use File::Spec;
## test that utf8 safe Perls are able to write and read back UTF8 
## character data. The offsets in a record directory are byte offsets
## (not character offsets), so they need to be calculated and used using
## the bytes pragma...see MARC::File::USMARC for details.

SKIP: {

    ## cannot do these tests unless we are running 5.8.1 or better
    skip "utf8 handling not safe", 8
        if ! MARC::File::utf8_safe();

    ## we are going to create a MARC record with a utf8 character in
    ## it (a Hebrew Aleph), write it to disk, and then attempt to
    ## read it back from disk as a MARC::Record.

    my $aleph = chr(0x05d0);
    CREATE_FILE: {
        my $r = MARC::Record->new();
        isa_ok( $r, 'MARC::Record' );

        my $f = MARC::Field->new( 245, 0, 0, a => $aleph, c => 'Mr. Foo' );
        isa_ok( $f, 'MARC::Field' );

        my $nadds = $r->append_fields( $f );
        is( $nadds, 1, "Added one field" );

        ## write record to disk, telling perl (as we should) that we
        ## will be writing utf8 unicode
        my $outfile = File::Spec->catfile( File::Spec->updir(), 't', 'utf8.marc' );
        open( OUT, ">$outfile" );
        binmode( OUT, ':utf8' );
        print OUT $r->as_usmarc();
        close( OUT );
    }

    ## open the file back up, get the record, and see if our Aleph
    ## is there

    REREAD_FILE: {
        my $rereadfile = File::Spec->catfile( File::Spec->updir(), 't', 'utf8.marc' );
        my $f = MARC::File::USMARC->in( $rereadfile );
        isa_ok( $f, 'MARC::File::USMARC' );

        my $r = $f->next();
        isa_ok( $r, 'MARC::Record' );

        is( scalar( $r->warnings() ), 0, 'Reading it generated no warnings' ); 
        diag( $r->warnings ) if $r->warnings;

        my $a = $r->field( 245 )->subfield( 'a' );
        ok( Encode::is_utf8( $a ), 'got utf8' );
        is( $a, $aleph, 'got aleph' );

        unlink( $rereadfile );
    }
} # SKIP

