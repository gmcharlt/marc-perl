use Test::More tests => 3;

use strict;
use MARC::Record;
use MARC::File::USMARC;
use MARC::File::Utils;
use Encode;

## test that utf8 safe Perls are able to write and read back UTF8 
## character data. The offsets in a record directory are byte offsets
## (not character offsets), so they need to be calculated and used using
## the bytes pragma...see MARC::File::USMARC for details.

SKIP: { 

    ## cannot do these tests unless we are running 5.8.1 or better
    skip "need Perl v5.8.1 or better for UTF8 testing", 3
        if ! MARC::File::Utils::utf8_safe();

    ## we are going to create a MARC record with a utf8 character in
    ## it (a Hebrew Aleph), write it to disk, and then attempt to
    ## read it back from disk as a MARC::Record.
    
    my $aleph = chr(0x05d0); 
    my $r1 = MARC::Record->new();
    $r1->append_fields( MARC::Field->new( 245, 0, 0, 
        a => $aleph, c => 'Mr. Foo' ) );

    ## write record to disk, telling perl (as we should) that we
    ## will be writing utf8 unicode
    
    open( OUT, ">t/utf8.marc" );
    binmode( OUT, ':utf8' );
    print OUT $r1->as_usmarc();
    close( OUT );

    ## open the file back up, get the record, and see if our Aleph
    ## is there
    
    my $f = MARC::File::USMARC->in( 't/utf8.marc' );
    my $r2 = $f->next();
    is( scalar( $r2->warnings() ), 0, 'no warnings' ); 

    my $a = $r2->field( 245 )->subfield( 'a' );
    ok( Encode::is_utf8( $a ), 'got utf8' );
    is( $a, $aleph, 'got aleph' );

    unlink( 't/utf8.marc' );

}

