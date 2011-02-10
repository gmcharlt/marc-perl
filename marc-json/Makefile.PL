use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'MARC::File::JSON',
    AUTHOR              => q{Galen Charlton <gmcharlt@gmail.com>},
    VERSION_FROM        => 'lib/MARC/File/JSON.pm',
    ABSTRACT_FROM       => 'lib/MARC/File/JSON.pm',
    ($ExtUtils::MakeMaker::VERSION >= 6.3002
      ? ('LICENSE'=> 'perl')
      : ()),
    PL_FILES            => {},
    PREREQ_PM => {
        'Test::More'     => 0,
        'JSON'          => 0,
        'MARC::Record'  => 2.0,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'MARC-File-JSON-*' },
);
