package Data::All::Format;

#   $Id: Format.pm,v 1.1.1.1.8.1 2004/04/16 17:10:33 dgrant Exp $

use strict;

#   CPAN Modules
use base qw( Class::Factory );


#   TODO: Allow external code to add new instance objects
Data::All::Format->register_factory_type( delim     => 'Data::All::Format::Delim' );
Data::All::Format->register_factory_type( fixed     => 'Data::All::Format::Fixed' );
Data::All::Format->register_factory_type( hash      => 'Data::All::Format::Hash' );


sub new()
{
     my ( $pkg, $type ) = ( shift, shift );
     my $class = $pkg->get_factory_class( $type );
     
     #  Use the base's new b/c it's will properly create the modules in
     #  spiffy styles
     return $class->new(@_);
}









#   $Log: Format.pm,v $
#   Revision 1.1.1.1.8.1  2004/04/16 17:10:33  dgrant
#   - Merging libperl-016 changes into the libperl-1-current trunk
#
#   Revision 1.1.1.1.2.1.2.1.2.1  2004/04/05 23:01:46  dgrant
#   - Database currently not working, but delim to delim is
#   - convert() works
#   - See examples/1 for working example
#
#   Revision 1.1.1.1.2.1.2.1  2004/03/26 21:38:38  dgrant
#   *** empty log message ***
#
#   Revision 1.1.1.1.2.1  2004/03/25 01:47:10  dgrant
#   - Initial import of modules
#   - Included CVS Id and Log variables
#   - Added use strict; to a few unlucky modules
#

1;



