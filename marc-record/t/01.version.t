# $Id: 01.version.t,v 1.1 2003/04/23 02:57:02 petdance Exp $

use strict;

use Test::More tests=>2;

BEGIN {
    use_ok( 'MARC::Record' );
}

my $ver = $MARC::Record::VERSION;

open( FH, $INC{'MARC/Record.pm'} ) or die $!;
while ( <FH> ) {
    chomp;
    pass(), exit if $_ eq "=head1 VERSION $ver";
}
fail( "Never found the version line" );


