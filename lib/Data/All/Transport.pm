package Data::Transport;

#   Converts a Data::All collection to a different format.
#   This could be another file with a different format
#   or even into a database

#   $Id: Transport.pm,v 1.1.1.1.6.1 2004/04/16 17:10:33 dgrant Exp $

use strict;
use warnings;


use Spiffy '-base';
use Data::All::Format;

use vars qw(@EXPORT $VERSION);

@EXPORT = qw();
$VERSION = 0.10;
    
                                            #   Configurable attributes
attribute '';                         #   
                                            #   State values
attribute '';       #   
                                            #   Containers
attribute '';                             #

sub filter;
filter 'default';                           #   A generic transport filter

spiffy_constructor 'transport';             #   A Spiffy constructor shortcut

#   Our Modules
sub paired_arguments    { qw() }
sub boolean_arguments   { qw() }





sub filter 
{
    my $package = caller;
    my ($filter) = @_;
    no strict 'refs';
    return if defined &{"${package}::$filter"};
    *{"${package}::$filter"} = sub { return @_ };
}






























#   $Log: Transport.pm,v $
#   Revision 1.1.1.1.6.1  2004/04/16 17:10:33  dgrant
#   - Merging libperl-016 changes into the libperl-1-current trunk
#
#   Revision 1.1.1.1.2.1.2.2  2004/03/25 20:25:10  dgrant
#   - Moved File.pm to FlatFile.pm
#
#   Revision 1.1.1.1.2.1.2.1  2004/03/25 19:29:37  dgrant
#   - Moved Data::Transport to Data::All:Transport
#
#   Revision 1.1.1.1.2.2  2004/03/25 02:08:11  dgrant
#   - Added skeleton filter (mostly so I don't forget about it)
#
#   Revision 1.1.1.1.2.1  2004/03/25 01:47:10  dgrant
#   - Initial import of modules
#   - Included CVS Id and Log variables
#   - Added use strict; to a few unlucky modules
#



1;
