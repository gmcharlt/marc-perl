use Test::More;

use File::Spec;
use File::Find;
use strict;

eval {
  require Test::Pod;
  Test::Pod->import;
};

my @files;

if ($@) {
  plan skip_all => "Test::Pod required for testing POD";
}
else {
  my $blib = File::Spec->catfile(qw(blib lib));
  find(\&wanted, $blib);
  plan tests => scalar @files;
  TODO: {
    local $TODO = "Haven't yet made the POD test the new stringent Pod::Checker";
    foreach my $file (@files) {
      pod_ok($file);
    }
  } # TODO
}

sub wanted {
  push @files, $File::Find::name if /\.p(l|m|od)$/;
}
