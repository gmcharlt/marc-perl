use Test::More tests=>2;

## test that we can load

BEGIN { use_ok('MARC::Charset'); }

## and create an object

BEGIN { 
    $cs = MARC::Charset->new();
    isa_ok($cs,'MARC::Charset',$cs); 
}

