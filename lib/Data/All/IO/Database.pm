package Data::All::IO::Database;

#   $Id: Database.pm,v 1.1.2.2.2.2.2.1.6.1.8.10 2004/05/06 15:47:45 dgrant Exp $


use strict;
use warnings;

use Data::All::IO::Base '-base';
use DBI;

use vars qw($VERSION);

$VERSION = 0.14;

internal 'DBH';
internal 'STH';



sub open($)
{
    my $self = shift;
    my $query = $self->path()->[3];

    $self->_create_dbh();               #   Open DB connection
    
    if ($query =~ /^SELECT/i)
    {
        $self->__STH($self->__DBH()->prepare($query));
        $self->__STH()->execute();
        $self->_extract_fields();
    }
    
    return $self->is_open(1);
}

sub close()
{
    my $self = shift;

    $self->__STH()->finish(), $self->__DBH()->commit()
        if ($self->__STH());

    $self->__DBH()->disconnect();
    $self->is_open(0);
    
    return;
}

sub nextrecord() {  $_[0]->__STH()->fetchrow_hashref() }


sub getrecord_array() 
{ 
    my $self = shift; 
    my $record = $self->__STH()->fetchrow_arrayref();

    return wantarray ? @{$record} : $record;
}

sub getrecords() 
{ 
    my $self = shift;
    
    return undef unless ($self->__STH()->rows);
    
    my (@records, $ref);
    while ($ref = $self->__STH()->fetchrow_arrayref())
    {
        push (@records, $ref);
    }

    #   Close the statement handle
    #$self->__STH()->finish();

    return wantarray ? @records : \@records;
    
}

sub putfields()
{
    my $self = shift;
    
    #   We don't do nothin' with fields for the database
    
    #   IDEA: Maybe we could use this call for creating a table
}


sub putrecord($;\%)
{
    my $self = shift;
    my ($record, $options) = @_;
    my @vars;
   
    #warn $self->path()->[3];
    
    $self->__STH($self->__DBH()->prepare($self->path()->[3]))
        unless $self->__STH();
        
    push(@vars, @{ $options->{'extra_pre_vars'} }) 
        if (defined($options->{'extra_pre_vars'}));
        
    push(@vars, @{ $self->hash_to_array($record) });
    
    push(@vars, @{ $options->{'extra_post_vars'} }) 
        if (defined($options->{'extra_post_vars'}));        
    
    $self->__STH()->execute(@vars);
}


sub putrecords()
{
    my $self = shift;
    my ($records, $options) = @_;

    my $query = $self->path()->[3];
    
    die("$self->putrecords() needs records") unless ($#{ $records }+1);
        
    $self->__STH($self->__DBH()->prepare($query));
    
    my $record;
    foreach my $rec (@{ $records })
    {
        $self->putrecord($rec, $options);
    }
    
    #   Close the statement handle
    $self->__STH()->finish();
    
}

sub count()
#   TODO: Refactor this count() functionality.
#   What about INSERT queries. We could keep track of how many were
#   successfully inserted. 
{
    my $self = shift;
    my $query = $self->path()->[3];
    my $count;
    
    return $count unless($query =~ /^\s*?SELECT/);
    
    $query =~ s/SELECT\s.+?\sFROM/SELECT COUNT(*) FROM/;
    
    $self->__STH($self->__DBH()->prepare($query))
        unless ($self->__STH());
    
    $self->__STH()->execute();
    
    $count = ($self->__STH()->fetchrow_array())[0];
    
    $self->__STH()->finish();
    
    return $count;
}

sub _create_dbh()
{
    my $self = shift;
    my $dbh = $self->_db_connect();
    
    ($dbh)
        ? $self->__DBH($dbh)
        : die("Cannot create DB Connection");
}

sub _create_sth()
{
    my $self = shift;
    my $sth = $self->__DBH()->prepare($self->location());
    
    ($sth)
        ? $self->__STH($sth)
        : die("Cannot prepare statement handle");
}

sub _db_connect()
{
    my $self = shift;
    return if ($self->is_open());
    return DBI->connect($self->_create_connect(), { RaiseError => 1, AutoCommit => 0 });
}

sub _create_connect()
{
    my $self = shift;
    return ($self->path()->[0],$self->path()->[1],$self->path()->[2]);
}

sub _extract_fields()
{
    my $self = shift;
    return if ($self->fields());
    
    $self->fields($self->__STH()->{'NAME'});
}



#   $Log: Database.pm,v $
#   Revision 1.1.2.2.2.2.2.1.6.1.8.10  2004/05/06 15:47:45  dgrant
#   *** empty log message ***
#
#   Revision 1.1.2.2.2.2.2.1.6.1.8.8  2004/05/05 16:46:49  dgrant
#   - Misc changes I should have commited on Friday when I made them.
#
#   Revision 1.1.2.2.2.2.2.1.6.1.8.6  2004/04/29 22:25:01  dgrant
#   *** empty log message ***
#
#   Revision 1.1.2.2.2.2.2.1.6.1.8.3  2004/04/28 23:51:43  dgrant
#   - Added transaction support
#
#   Revision 1.1.2.2.2.2.2.1.6.1  2004/04/08 23:08:56  dgrant
#   - Renamed getrecord() as getrecord_array()
#
#   Revision 1.1.2.2.2.2.2.1  2004/04/06 00:12:54  dgrant
#   - pre-011 version commit
#
#   Revision 1.1.2.2.2.2  2004/04/05 23:01:47  dgrant
#   - Database currently not working, but delim to delim is
#   - convert() works
#   - See examples/1 for working example
#
#   Revision 1.1.2.2.2.1  2004/03/31 22:36:26  dgrant
#   ongoing...
#
#   Revision 1.1.2.2  2004/03/30 22:43:29  dgrant
#   *** empty log message ***
#
#   Revision 1.1.2.1  2004/03/26 21:36:53  dgrant
#   - Added IO::Database
#   - NOTE: Not currently functioning
#
#   Revision 1.1.1.1.2.1  2004/03/25 01:47:11  dgrant
#   - Initial import of modules
#   - Included CVS Id and Log variables
#   - Added use strict; to a few unlucky modules
#


1;