use Test::More;
eval "use Test::Pod::Coverage 0.02";
plan skip_all => "Test::Pod::Coverage 0.02 required for testing POD coverage" if $@;

plan tests=>7;

pod_coverage_ok( "MARC::Record" );
pod_coverage_ok( "MARC::Field" );
pod_coverage_ok( "MARC::Batch" );
pod_coverage_ok( "MARC::File" );
pod_coverage_ok( "MARC::File::MicroLIF" );
pod_coverage_ok( "MARC::File::USMARC" );
pod_coverage_ok( "MARC::Lint" );
