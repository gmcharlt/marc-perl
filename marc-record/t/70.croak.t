use Test::More tests=>4;

use MARC::Record;
use MARC::Field;

my $record = MARC::Record->new();

my $f100 = MARC::Field->new( '100', '', '', 'a' => 'author' );
my $f200 = MARC::Field->new( '245', '', '', 'b' => 'title' );

INSERT_FIELDS_AFTER: {

    eval {
	$record->insert_fields_after( $f100, 'blah' );
    };

    like( $@, qr/All arguments must be MARC::Field objects/, 
	'insert_fields_after() croaks appropriately' ); 

}


INSERT_FIELDS_BEFORE: {

    eval { 
	$record->insert_fields_before( $f100, 'blah' );
    };

    like( $@, qr/All arguments must be MARC::Field objects/,
	'insert_fields_before() croaks appropriately' );

}


INSERT_GROUPED_FIELD: {

    eval {
	$record->insert_grouped_field( 'blah' );
    };

    like( $@, qr/Argument must be MARC::Field object/,
	'insert_grouped_field() croaks appropriately' );

}


APPEND_FIELDS: {

    eval {
	$record->append_fields( 'blah' );
    };

    like( $@, qr/Arguments must be MARC::Field objects/,
	'append_fields() croaks appropriately' );

}


