package Data::All::IO::FTP;

#   $Id: FTP.pm,v 1.1.2.1 2004/05/10 07:23:30 dgrant Exp $


use strict;
use warnings;

use Data::All::IO::Plain '-base';
use Net::FTP::Common;
use FileHandle;

our $VERSION = 0.10;


sub init()
#   Called in Data::All::IO::new
#   TODO: Create Format::Hash
{
    my ($self, $args) = @_;
    
    populate $self => $args;

    warn " -> path:", join ', ', @{ $self->path() };
    warn " -> format:", $self->format()->{'type'};
    warn " -> io:", $self->ioconf->{'type'};
    
    $self->__FORMAT($self->_load_format());
    
    
    return $self;
}


#   $Log: FTP.pm,v $
#   Revision 1.1.2.1  2004/05/10 07:23:30  dgrant
#   - Added Data/All/IO/FTP.pm
#


1;