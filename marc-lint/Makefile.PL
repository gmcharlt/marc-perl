use strict;
use ExtUtils::MakeMaker;

&WriteMakefile(
    NAME          => 'MARC::Lint',
    DISTNAME      => 'MARC-Lint',
    VERSION_FROM  => 'lib/MARC/Lint.pm',
    ABSTRACT_FROM => 'lib/MARC/Lint.pm',
    AUTHOR        => 'Bryan Baldus <bryan.baldus@quality-books.com>',
    PREREQ_PM     => {
                        'Test::More' => 0,
                        'MARC::Record' => 0,
                     },
    EXE_FILES     => [ qw( bin/marclint ) ],
);
