package MARC::Charset::EastAsian;

use MARC::Charset::Generic qw( :all );
use base qw( MARC::Charset::Generic );

=head1 NAME

MARC::Charset::EastAsian - MARC8/UTF8 mappings 

=head1 SYNOPSIS

 use MARC::Charset::EastAsian;
 my $cs = MARC::Charset::EastAsian->new();

=head1 DESCRIPTION

MARC::Charset::EastAsian provides a mapping between the MARC8 EastAsian 
character set and Unicode(UTF8). It is typically used by MARC::Charset, so 
you probably don't need to use this yourself. 

Because there are so many EastAsian characters, lookup() uses a tied Berkeley DB
file so as to conserve memory. This db was built and installed when you
installed MARC::Charset.

MARC::Charset::EastAsian inherits from MARC::Charset::Generic, so you'll need
to look at those docs as well to see all the available methods.

=head1 METHODS

=cut 

use strict;
use DB_File;
use Config;
use constant CHAR_SIZE	    => 3;

## trickery to locate where we can find EastAsian.db when we are 
## testing and after install.

my $db = 'blib/lib/MARC/Charset/EastAsian.db';
if ( ! -f $db ) { $db .= $Config{ 'sitelib' } . '/MARC/Charset/EastAsian.db'; }
if ( ! -f $db ) { die "couldn't located EastAsian.db" };
tie( my %marc2unicode, 'DB_File', $db, O_RDONLY )
    || die "unable to locate EastAsian.db at $db!";

=head1 

The constructor, which will return you a MARC::Charset::EastAsian object.

=cut


sub new {
    my $class = shift;
    return bless 
	{
	    NAME	=> 'EastAsian',
	    CHARSETCODE	=> CJK,
	    CHARSIZE	=> 3
	}, ref($class) || $class;
}

=head1 lookup()

The workhorse method that does the lookup. Pass it an a character and you'll
get back the UTF8 character.

=cut


sub lookup {
    my ($self,$char) = @_; 
    my $hex = $marc2unicode{$char};
    return( chr($hex) ) if $hex;
    return(undef);
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

=item Nothing

=back

=head1 SEE ALSO

=over 4

=item MARC::Charset::Generic

=back

=head1 AUTHORS

=over 4

=item Ed Summers <ehs@pobox.com>

=back

=cut

1;

