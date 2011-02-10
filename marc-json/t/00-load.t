#!perl -T

use Test::More tests => 1;

BEGIN {
    use_ok( 'MARC::File::JSON' ) || print "Bail out!
";
}

diag( "Testing MARC::File::JSON $MARC::File::JSON::VERSION, Perl $], $^X" );
