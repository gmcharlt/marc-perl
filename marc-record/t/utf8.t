use Test::More tests => 2;

use strict;
use MARC::Record;
use MARC::File::USMARC;

## MARC::Record is not able to read MARC data back from disk if the
## record has Unicode (UTF-8) in it. This may be for a variety of
## reasons: calculating leader lengths based on character rather than
## byte length; using directory values and substr() to extra fields when
## substr uses character lengths rather than byte lengths; open files
## from disk without using the ':utf8' pragma, etc.

TODO: {

    SKIP: { 

	## only do these tests with the first stable release of perl 
	## that can do unicode.
	if ( $] < 5.008 ) { 
	    skip( 'need perl5.8 or greater to test unicode', 1 );
	}

	local $TODO = 'utf8 handling';

	## we are going to create a MARC record with a utf8 character in
	## it (a Hebrew Aleph), write it to disk, and then attempt to
	## read it back from disk as a MARC::Record.
	
	my $aleph = chr(0x05d0); 
	my $r1 = MARC::Record->new();
	$r1->append_fields( MARC::Field->new( 245, 0, 0, a => $aleph ) );

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
	my $a = $r2->field( 245 )->subfield( 'a' );
	is( length( $a ), length( $aleph ), 'character length' );
	is( ord( $r2->field( 245 )->subfield( 'a' ) ), ord( $aleph ), 
	    'character value' );

	unlink( 't/utf8.marc' );

    }

}

