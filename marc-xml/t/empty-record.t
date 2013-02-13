use strict;
use warnings;
use Test::More tests => 10;
use MARC::Record;
use MARC::File::XML;
use MARC::Batch;

foreach my $file (qw{t/empty-record.xml t/empty-record-2.xml}) {
    open my $IN, '<', $file;
    my $xml = join('', <$IN>);
    close $IN;
    my $r;
    eval { $r = MARC::Record->new_from_xml($xml, 'UTF-8'); };
    ok(!$@, "do not throw an exception when parsing an empty record ($file)");
    my @fields = $r->fields();
    is(@fields, 0, "MARC::Record object is empty ($file)");
}

my @titles = (
    'ActivePerl with ASP and ADO / Tobias Martinsson.',
    'Programming the Perl DBI / Alligator Descartes and Tim Bunce.',
    '',
    'Perl : programmer\'s reference / Martin C. Brown.',
    '',
    'Perl : the complete reference / Martin C. Brown.',
);
my $batch = MARC::Batch->new( 'XML', 't/batch-with-empty.xml' );
my $count = 0;
while ( my $record = $batch->next() ) {
    $count++;
    is( $record->title(), shift(@titles), "found title $count" );
}
