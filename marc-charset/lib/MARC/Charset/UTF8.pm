package MARC::Charset::EastAsian;

=head1 NAME

MARC::Charset::UTF8 - UTF-8 => MARC-8 mapping 

=head1 SYNOPSIS

 use MARC::Charset::UTF8;
 my $cs = MARC::Charset::UTF8->new();

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
use constant CHAR_SIZE	    => 3;

## trickery to locate where we can find UTF9/db when we are 
## testing and after install.

my $db .= $Config{ 'sitelib' } . '/MARC/Charset/UTF8.db';
if ( ! -f $db ) { $db = 'blib/lib/MARC/Charset/UTF8.db'; }
if ( ! -f $db ) { die "couldn't locate UTF8.db" };
tie( my %unicode2marc, 'DB_File', $db, O_RDONLY )
    || die "unable to locate UTF8.db at $db!";

my %combining;

=head1 

The constructor, which will return you a MARC::Charset::UTF8 object.

=cut


sub new {
    my $class = shift;
    return bless {}, ref($class) || $class;
}

=head1 name()

Returns the name of the character set.

=cut


sub name {
    return('UTF8');
}

=head1 lookup()

The workhorse method that does the lookup. Pass it an a character and you'll
get back the MARC8 character.

=cut


sub lookup {
    my ($self,$char) = @_; 
    my $hex = $marc2unicode{$char};
    return( chr(hex($hex) ) ) if $hex;
    return(undef);
}

=head1 combining()

Pass it a character and you'll get back a true value (1) if the character is 
a combining character, and false (undef) if it is not.

=cut


sub combining {
    return(undef);
}

=head1 getCharSize()

Returns the number of bytes in each character of this character set.

=cut


sub getCharSize {
    return(CHAR_SIZE);
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

