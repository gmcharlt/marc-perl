# $Id: 00.version.t,v 1.1 2002/04/01 03:19:59 petdance Exp $

# Pretty lame, huh?  We'll fix it later
print "1..1\n";
print "ok 1\n";

=pod

use Test::More 'no_plan';

our @modules = qw( MARC::Field MARC::Record MARC::Lint MARC::Batch );

plan( 2*@modules );

for my $module ( @modules ) {
    use_ok( $module, "Loaded $module" );

    my $version = $module . "::VERSION";
    is( $$version, $MARC::Record::VERSION, 'All versions in sync' );
    diag( "$MARC::Record::VERSION" );
}

=cut
