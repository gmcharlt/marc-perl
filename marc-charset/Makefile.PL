use 5.8.0;
use ExtUtils::MakeMaker;

# try to build the character mapping db
build_db();

WriteMakefile(
    NAME            => 'MARC::Charset',
    DISTNAME        => 'MARC-Charset',
    VERSION_FROM    => 'lib/MARC/Charset.pm',
    ABSTRACT_FROM   => 'lib/MARC/Charset.pm',
    AUTHOR          => 'Ed Summers <ehs@pobox.com>',
    PMLIBDIRS       => ['lib'],
    PREREQ_FATAL    => 1,
    PREREQ_PM       => {
                            'Test::More'            => 0, 
                            'XML::SAX'              => 0,
                            'Class::Accessor'       => 0,
                            'Unicode::Normalize'    => 0,
                       },
);

# build_db will return immediately if we can't use
# MARC::Charset::Compiler which will typically 
# happen when dependencies aren't met

sub build_db
{
    eval('use lib "lib"; use MARC::Charset::Compiler');
    return if $@;

    print "compiling marc8/utf8 database, please be patient\n";
    my $compiler = MARC::Charset::Compiler->new();
    $compiler->compile('etc/codetables.xml');
}
