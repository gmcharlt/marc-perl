use Test::More tests => 8;

use MARC::Charset;

BEGIN { 
    use_ok( 'MARC::Charset::ArabicBasic' );
    use_ok( 'MARC::Charset::ArabicExtended' );
}

my $cs = MARC::Charset->new();
isa_ok( $cs, 'MARC::Charset', 'MARC::Charset::new()' );

## make sure we get our default character sets

isa_ok( $cs->g0(), 'MARC::Charset::ASCII' );
isa_ok( $cs->g1(), 'MARC::Charset::Ansel' );

## now make sure we can designate character sets with the constructor
$cs = MARC::Charset->new(
    g0	=> MARC::Charset::ArabicBasic->new(),
    g1	=> MARC::Charset::ArabicExtended->new()
);

isa_ok( $cs, 'MARC::Charset' );
isa_ok( $cs->g0(), 'MARC::Charset::ArabicBasic' );
isa_ok( $cs->g1(), 'MARC::Charset::ArabicExtended' );

