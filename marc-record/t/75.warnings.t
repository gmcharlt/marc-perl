use Test::More tests=>5;
use strict;

BEGIN: {
    use_ok( 'MARC::Batch' );
}

## when strict is on, errors cause next() to return undef

STRICT_ON: {

    my $batch = MARC::Batch->new( 'USMARC', 't/badldr.usmarc' );
    $batch->warnings_off(); # avoid clutter on STDERR
    $batch->strict_on(); # the default, but might as well test

    my $count = 0;
    while ( my $r = $batch->next() ) {
	$count++;
    }
    
    my @warnings = $batch->warnings();
    is( scalar(@warnings), 2, "warnings() w/ strict on" );
    is( $count, 2, "next() w/ strict on" );

}

## when strict is off you can keep on reading past errors

STRICT_OFF: {

    my $batch = MARC::Batch->new( 'USMARC', 't/badldr.usmarc' );
    $batch->warnings_off(); # avoid clutter on STDERR
    $batch->strict_off(); # turning off default behavior
    
    my $count = 0;
    while ( my $r = $batch->next() ) {
	$count++;
    }

    my @warnings = $batch->warnings();
    is( scalar(@warnings), 13, "warnings() w/ strict off" );
    is( $count, 8, "next() w/ strict off" );

}
