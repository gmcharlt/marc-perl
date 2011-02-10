#!perl -Tw

use strict;
use warnings;

use Test::More tests => 6;

use File::Spec;

BEGIN {
    use_ok( 'MARC::Record' );
    use_ok( 'MARC::File::USMARC' );
    use_ok( 'MARC::File::JSON' );
}

my $blob_filename = File::Spec->catfile( 't', 'rsinger-example.usmarc' );
my $json_filename = File::Spec->catfile( 't', 'rsinger-example.json' );

open BLOB, "<$blob_filename";
my $blob = <BLOB>;
close BLOB;
open JSON, "<$json_filename";
my $json = <JSON>;
close JSON;

my $marc_from_blob = MARC::Record->new_from_usmarc($blob);
is(MARC::File::JSON::encode($marc_from_blob), $json, 'ISO2709 => JSON');

my $marc_from_json = MARC::File::JSON::decode($json);
is(MARC::File::USMARC->encode($marc_from_json), $blob, 'JSON => ISO2709');

my $wanted = sub {
    my $tag = shift;
    return $tag ne '035';
};

# try a filter function
$marc_from_json = MARC::File::JSON::decode($json, $wanted);
$marc_from_blob->delete_fields($marc_from_blob->field('035'));
is(MARC::File::USMARC->encode($marc_from_json), $marc_from_blob->as_usmarc(), 'JSON => ISO2709 with filter');
