# $Id: decode-filter.t,v 1.2 2003/02/25 20:42:07 petdance Exp $
# Test creating a MARC record for the Camel book
#
# Bugs, comments, suggestions welcome: marc@petdance.com

use strict;

use Test::More tests => 2;

BEGIN {
    use_ok( 'MARC::Record' );
}


sub wanted {
    my $tag = shift;
    my $data = shift;

    return $tag == 245 || $tag >= 600;
}

my $blob = "00397nam  22001458a 4500001001200000003000600012010001600018100001700034245006800051250001200119260004300131650003700174700002300211700001700234\x1Efol05865967\x1EIMchF\x1E  \x1Fa   00055799\x1E1 \x1FaWall, Larry.\x1E10\x1FaProgramming Perl / \x1FcLarry Wall, Tom Christiansen & Jon Orwant.\x1E  \x1Fa3rd ed.\x1E  \x1FaCambridge, Mass. : \x1FbO'Reilly, \x1Fc2000.\x1E 0\x1FaPerl (Computer program language)\x1E1 \x1FaChristiansen, Tom.\x1E1 \x1FaOrwant, Jon.\x1E\x1D";

my $marc = MARC::Record->new_from_usmarc( $blob, \&wanted );
use Data::Dumper;
#print Dumper( $marc ), "\n";

my $expected = join( "", <DATA> );
chomp $expected;

my $generated = $marc->as_formatted;
chomp $generated;

is( $generated, $expected, 'as_formatted()' );

__END__
LDR 00397nam  22001458a 4500
245 10 _aProgramming Perl / 
       _cLarry Wall, Tom Christiansen & Jon Orwant.
650  0 _aPerl (Computer program language)
700 1  _aChristiansen, Tom.
700 1  _aOrwant, Jon.
