package MARC::Charset::UTF8;

use MARC::Charset::Generic qw( :all );
use base qw( MARC::Charset::Generic ); 

=head1 NAME

MARC::Charset::UTF8 - UTF-8 => MARC-8 mapping 

=head1 SYNOPSIS

 use MARC::Charset::UTF8;
 my $cs = MARC::Charset::UTF8->new();

 ## convert some utf8 to marc8
 my $marc8 = $cs->to_marc8( $unicode );

 ## see what charsets have been used so far by this charset object
 my @charsets = $cs->charsets();

 ## what is the current G0 charset
 my $g0 = $cs->g0();

 ## what is the current G1 charset
 my $g1 = $cs->g1();

=head1 DESCRIPTION

Unlike all the other MARC::Charset::* classes, MARC::Charset::UTF8 attempts to
convert a Unicode character into it's MARC-8 equivalent. Obviously this is a
lossy process since MARC-8 doesn't support anywhere near the wide variety of
characters that Unicode does...but it does its best.

When you installed MARC::Charset the other MARC::Charset::* mappings were turned
on their head to create one Berkeley database to house the mapping. If you are
curious you should be able to find this Berkeley DB living in the same directory
which you installed MARC::Charset::UTF8 into.

=head1 METHODS

=cut 

use strict;
use DB_File;
use Config;

## trickery to locate where we can find UTF8/db when we are 
## testing and after install.

my $db .= $Config{ 'sitelib' } . '/MARC/Charset/UTF8.db';
if ( ! -f $db ) { $db = 'blib/lib/MARC/Charset/UTF8.db'; }
if ( ! -f $db ) { die "couldn't locate UTF8.db" };
tie( my %unicode2marc, 'DB_File', $db, O_RDONLY );
if ( !%unicode2marc ) { die "unable to locate UTF8.db at $db!"; }

print STDERR "Tied: $db\n";

my %combining;

=head1 new()

The constructor, which will return you a MARC::Charset::UTF8 object.

=cut


sub new {
    my $class = shift;
    return bless 
	{
	    NAME	=> 'UTF8',
	    CHARSETCODE	=> '-',
	    CHARSIZE	=> 1
	}, ref($class) || $class;
}

=head1 lookup()

The workhorse method that does the lookup. Pass it an a character and you'll
get back some data identifying a MARC8 character. 

=cut


sub lookup {
    my ($self,$char) = @_; 
    return( MARC::Charset::_unpack( $unicode2marc{ ord( $char ) } ) );
}

=head1 combining()

Pass it a character and you'll get back a true value (1) if the character is 
a combining character, and false (undef) if it is not.

=cut

sub combining {
    return(undef);
}

=head1 TODO

=over 4 

=item *

=back

=head1 AUTHORS

=over 4

=item Ed Summers <ehs@pobox.com>

=back

=cut

1;

