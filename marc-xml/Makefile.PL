use ExtUtils::MakeMaker;

WriteMakefile(
    'NAME'		=> 'MARC-XML',
    'DISTNAME'		=> 'MARC-XML',
    'VERSION_FROM'	=> 'lib/MARC/File/XML.pm', 
    'PMLIBDIRS'		=> [ qw( lib/ ) ],
    'AUTHOR'		=> 'Ed Summers <ehs@pobox.com>',
    'LICENSE'       => 'perl',
    'PREREQ_PM'		=> { 
			    'XML::SAX'		=> 0.12,
			    'MARC::Record'	=> 2.0,
			    'MARC::Charset'	=> 0.98,
			    },
    'EXE_FILES'         => [ qw( bin/marc2xml bin/xml2marc ) ]
);

