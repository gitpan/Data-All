package Data::All::IO;

#   $Id: IO.pm,v 1.1.1.1.8.1 2004/04/16 17:10:33 dgrant Exp $

use strict;

use base qw( Class::Factory );


#   TODO: Allow external code to modify this list
Data::All::IO->register_factory_type( xml   => 'Data::All::IO::XML' );
Data::All::IO->register_factory_type( plain => 'Data::All::IO::Plain' );
Data::All::IO->register_factory_type( db    => 'Data::All::IO::Database' );



sub new()
{
     my ( $pkg, $type ) = ( shift, shift );
     my $class = $pkg->get_factory_class( $type );
     
     #  Use the base's new b/c it's will properly create the modules in
     #  spiffy styles
     return $class->new(@_);
}




#   $Log: IO.pm,v $
#   Revision 1.1.1.1.8.1  2004/04/16 17:10:33  dgrant
#   - Merging libperl-016 changes into the libperl-1-current trunk
#
#   Revision 1.1.1.1.2.1.2.3.2.1  2004/04/05 23:01:46  dgrant
#   - Database currently not working, but delim to delim is
#   - convert() works
#   - See examples/1 for working example
#
#   Revision 1.1.1.1.2.1.2.3  2004/03/30 22:43:28  dgrant
#   *** empty log message ***
#
#   Revision 1.1.1.1.2.1.2.2  2004/03/26 21:38:38  dgrant
#   *** empty log message ***
#
#   Revision 1.1.1.1.2.1  2004/03/25 01:47:10  dgrant
#   - Initial import of modules
#   - Included CVS Id and Log variables
#   - Added use strict; to a few unlucky modules
#

1;