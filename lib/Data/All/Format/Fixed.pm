package Data::All::Format::Fixed;


#   $Id: Fixed.pm,v 1.1.1.1.8.1 2004/04/16 17:10:33 dgrant Exp $


use strict;
use warnings;

use Data::All::Format::Base '-base';

use vars qw(@EXPORT $VERSION);

@EXPORT = qw();
$VERSION = 0.10;


attribute 'lengths' => [];
attribute 'break'   => "\n";


sub expand($);
sub contract(\@);


#   TODO: Forward look to defined lengths if they are blank

sub expand($)
{
    my $self = shift;
    my $record = shift;
    my $template = $self->pack_template();
    
    return unpack($template, $record);
}

sub contract(\@)
{
    my $self = shift;
    my $values = shift;
    my $template = $self->pack_template();
    #print Dumper($values) unless($values->[4]);
    
    return pack($template, @{ $values }).$self->break();
}


sub pack_template()
{
    my $self = shift;
    my @template;
    
    foreach my $e (@{ $self->lengths })
    {
        push(@template, "A$e");
    }
    
    return !wantarray ? join(' ', @template) : @template; 
}













#   $Log: Fixed.pm,v $
#   Revision 1.1.1.1.8.1  2004/04/16 17:10:33  dgrant
#   - Merging libperl-016 changes into the libperl-1-current trunk
#
#   Revision 1.1.1.1.2.1.2.1.18.1.4.1  2004/04/15 23:50:39  dgrant
#   - Changed Format::Delim to use Text::Parsewords (again). There
#     is a bug in Text::Parsewords that causes it to bawk when a
#     ' (single quote) character is present in the string (BOO!).
#     I wrote a temp work around (replace it with \'), but we will
#     need to do something about that.
#
#   Revision 1.1.1.1.2.1.2.1.18.1  2004/04/08 16:43:08  dgrant
#   - In the midst of changes mainly for upgrading the delimited functionality
#
#   Revision 1.1.1.1.2.1.2.1  2004/03/26 21:38:38  dgrant
#   *** empty log message ***
#
#   Revision 1.1.1.1.2.1  2004/03/25 01:47:11  dgrant
#   - Initial import of modules
#   - Included CVS Id and Log variables
#   - Added use strict; to a few unlucky modules
#

1;