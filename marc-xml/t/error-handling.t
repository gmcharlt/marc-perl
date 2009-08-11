use strict;
use warnings;
use Test::More tests => 1; 
use MARC::Record;
use MARC::File::XML;

open IN, '<', 't/invalid.xml';
my $xml = join('', <IN>);
close IN;
my $r;
eval { $r = MARC::Record->new_from_xml($xml, 'UTF-8'); };
if ($@) {
    diag($@);
    ok($@ =~ /found MARCXML element/, 'failed with sensible exception message');
} else {
    fail('should have thrown an exception trying to parse XML from t/invalid.xml');
}
