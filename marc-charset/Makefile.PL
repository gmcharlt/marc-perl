use 5.8.0;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME            => 'MARC::Charset',
    DISTNAME        => 'MARC-Charset',
    VERSION_FROM    => 'lib/MARC/Charset.pm',
    ABSTRACT_FROM   => 'lib/MARC/Charset.pm',
    AUTHOR          => 'Ed Summers <ehs@pobox.com>',
    PMLIBDIRS       => ['lib'],
    PREREQ_PM       => {
                            'Test::More'            => 0, 
                            'XML::SAX'              => 0,
                            'Class::Accessor'       => 0,
                            'Unicode::Normalize'    => 0,
                            'GDBM_File'             => 0,
                       },
);
