package Data::All;

#   Data::All - Access to data in many formats from many places

#   $Id: All.pm,v 1.1.1.1.8.3 2004/04/16 20:45:03 dgrant Exp $

use strict;
use warnings;
use diagnostics;

use Data::All::Base '-base';    #   Spiffy
use Data::All::IO;

our $VERSION = 0.016;
our @EXPORT = qw(collection);


##  Interface
sub show_fields;    #   returns an arrayref of field names
sub collection;     #   A shortcut for open() and read()
sub is_open;
sub convert;        #   Change formats
sub close;
sub read;
sub open;

spiffy_constructor 'da';


##  External Structure
attribute 'moniker';
attribute 'filters';
attribute 'profile';
attribute 'fields';
attribute 'format';
attribute 'ioconf';
attribute 'path'; 


#   A Spiffy thing
sub paired_arguments    { qw(path ioconf format filters profile fields moniker) }
sub boolean_arguments   { qw() }


sub is_open(;$) 
{ 
    my $self = shift;
    my $moniker = shift || $self->moniker;
    
    return $self->__DATA()->{$moniker}->is_open()
}

sub collection(%)
{
    my ($conf1, $conf2) = @_;
    my $itself = new('Data::All', %{ $conf1 });
    
    $itself->open();
    return $itself->read();
}

sub open(;$)
{
    my $self = shift;
    my $moniker = shift || $self->moniker;
    
    $self->__DATA()->{$moniker}->open();
    
    unless ($self->is_open())
    {
        $self->__ERROR($self->__DATA()->{$moniker}->__ERROR());
        warn "Cannot open ", $self->__DATA()->{$moniker}->create_path();
        die;
    }
        
    
    return $self->is_open();
}

sub close(;$)
{
    my $self = shift;
    my $moniker = shift || $self->moniker;
    $self->__DATA()->{$moniker}->close();
}

sub show_fields(;$)
{
    my $self = shift;
    my $moniker = shift || $self->moniker;

    $self->__DATA()->{$moniker}->fields;
}

sub read(;$$)
{
    my $self = shift; 
    my $moniker = shift || $self->moniker;
    my ($start, $count) = (shift || 0, shift || undef); 

    my $records = $self->__DATA()->{$moniker}->getrecords($start, $count);
    
    return !wantarray ? $records :   @{ $records };
}

sub convert
#   TODO: Clean up convert()
{
    my $self = shift;
    my @args = @_;
    my $moniker = $self->moniker;
    my ($from, $to, $from_records);
    
    if (!$args[1])
    {
        $from = $self->__DATA()->{$moniker};
        $self->_parse_args($args[0]);
        $to = $self->_load_IO($args[0]);
        
        $from->open() unless $from->is_open();

        $from_records = $from->getrecords();
    }
    elsif (ref($args[1]) eq 'HASH')
    {
        $self->_parse_args($args[0]);
        $self->_parse_args($args[1]);
        $from = $self->_load_IO($args[0]);
        $to = $self->_load_IO($args[1]);
        $from->open();

        $from_records = $from->getrecords();
    }
    elsif (ref($args[1]) eq 'ARRAY')
    {
        $self->_parse_args($args[0]);
        $to = $self->_load_IO($args[0]);
        $from_records = $args[1];
    }
    
    $to->open();
    
    $to->fields($from->fields) unless ($#{ $to->fields() });

    $to->putfields();
    $to->putrecords($from_records);
    
    return;
}


sub write(;$$)
{
    my $self = shift;
    my $moniker = shift || $self->moniker;
    my ($start, $count) = (shift || 0, shift || 0); 
        
}



sub _load_IO(\%)
{
    my $self = shift;
    my ($ioconf, $format, $path, $fields) = @{ shift() }{'ioconf','format','path','fields'};
    
    return Data::All::IO->new($ioconf->{'type'}, 
        { ioconf => $ioconf, format => $format, path=>$path, fields => $fields});
}


sub _parse_args()
#   Convert arrayref args into hashref, process determinable values, 
#   and apply defaults to the rest. We can also through a horrible
#   error at this point if there isn't enoguh info for Data::All to
#   continue.
{
    my $self = shift;
    my $args = shift;
   
    #   Make sure path is an array ref
    $args->{'path'} = [$args->{'path'}]  if (ref($args->{'path'}) ne 'ARRAY');
        
    #   TODO: Allow collection('filename.csv', 'profile'); usage
    $self->_apply_profile_to_args($args);
    
    $args->{'path'} = [$args->{'path'}]
        unless (ref($args->{'path'}) eq 'ARRAY');
    
    for my $a (keys %{ $self->__default() })
    #   Apply default values to data collection configuration. Amplify arrayref 
    #   configs into hashref configs using the a2h_templates where appropriate.
    { 
        if (ref($args->{$a}) eq 'ARRAY')
        {
            my (%hash, $templ);
            $templ = join '', $a, '.', $args->{$a}->[0];
            @hash{@{$self->__a2h_template()->{$templ}}} = @{ $args->{$a} };
                        
            $args->{$a} = \%hash;
        }
        
        $self->_apply_default_to($a, $args);
    }
    
    return if ($args->{'moniker'});
    
    $args->{'moniker'} = ($args->{'ioconf'}->{'type'} ne 'db')
        ? join('', @{ $args->{'path'} })
        #: $args->{'path'}->[0];
        : '_';
}

sub _apply_profile_to_args(\%)
#   Populate format within args based on a preconfigured profile
{
    my $self = shift;
    my $args = shift;
    my $p = $args->{'profile'} || $self->__default()->{'profile'};
    
    return if (exists($args->{'format'}));
    
    die("There is no profile for type $p ") 
        unless ($p && exists($self->__profile()->{$p}));
        
    #   Set the format using the requested profile
    $args->{'format'} = $self->__profile()->{$p};
    return;
}

sub _apply_default_to()
#   Set a default value to a particular attribute.
#   TODO: Allow setting of individual attribute fields
{
    my $self = shift;
    my ($a, $args) = @_;
    $args->{$a} = $self->__default()->{$a}
        unless (exists($args->{$a}));
    
    return unless (ref($args->{$a}) eq 'HASH');
    
    foreach my $c (keys %{ $self->__default()->{$a} })
    {
        $args->{$a}->{$c} = $self->__default()->{$a}->{$c}
            unless (defined($args->{$a}->{$c}));
    }

}


#   CONSTRUCTOR RELATED
sub init()
#   Rekindle all that we are
{
    my ($self) = @_; 
    my $args = $self->parse_arguments(@_);
    
    $self->_parse_args($args); 
    populate $self => $args;
    
    #   TODO: Allow me to not have to instantiate without creating a moniker
    #   TODO: Allow me to pass moniker as the first argument

    #   Store the Data::All::IO module in the __DATA internal hashref
    #   using the moniker as a key. Note: like values will be overridden!
    #   The default moniker is the filename.
    $self->__DATA({$args->{'moniker'} => $self->_load_IO($args)});

    return $self;
}



#   INTERNAL ATTRIBUTES
sub internal;

#   Contains Data::All::IO::* object by moniker
internal 'DATA'        => {};  

internal 'profile'     =>      
#   Hardcoded/commonly used format configs
{
    csv     => ['delim', "\n", ',', '"', '\\'],
    tab     => ['delim', "\n", "\t", '', '']
};

internal 'a2h_template'  =>    
#   Templates for converting arrayref configurations to 
#   internally used, easy to handle hashref configs. See _parse_args().
{
    'format.delim'      => ['type','break','delim','quote','escape'],
    'format.fixed'      => ['type','break','lengths'],
    'ioconf.plain'      => ['type','perm','with_original'],
    'ioconf.db'         => ['type','perm','with_original']
};

internal 'default'     =>
#   Default values for configuration variables
{
    profile => 'csv',
    filters => '',
    ioconf  => 
    { 
        type    => 'plain', 
        perm    => 'r', 
        with_original => 0 
    },
    format  => 
    { 
        type    => 'delim', 
        
        #   TODO: fix defaults
        #   Delim defaults
        #break   => "\n",
        #delim   => ',',
        #quote   => '"',
        #escape  => '\\',
        
        #   Fixed defaults, DB Defaults, XML Defaults
        #   NONE!
    }
};





#   $Log: All.pm,v $
#   Revision 1.1.1.1.8.3  2004/04/16 20:45:03  dgrant
#   *** empty log message ***
#
#   Revision 1.1.1.1.8.2  2004/04/16 19:01:16  dgrant
#   - Fixed Data::All::fields() bug (overlapped the attribute fields). Renamed 
#   to show_fields()
#
#   Revision 1.1.1.1.8.1  2004/04/16 17:10:32  dgrant
#   - Merging libperl-016 changes into the libperl-1-current trunk
#   - Changed Format::Delim to use Text::Parsewords (again). There
#     is a bug in Text::Parsewords that causes it to bawk when a
#     ' (single quote) character is present in the string (BOO!).
#     I wrote a temp work around (replace it with \'), but we will
#     need to do something about that.
#
#   Revision 1.1.1.1.2.6  2004/03/25 02:06:54  dgrant
#   - Added use perl 5.6
#   - In the midst of changes mainly for upgrading the delimited functionality
#   - pre-011 version commit
#   - Database currently not working, but delim to delim is
#   - convert() works
#   - See examples/1 for working example
#
#   Revision 1.1.1.1.2.5  2004/03/25 01:47:09  dgrant
#   - Initial import of modules
#   - Included CVS Id and Log variables
#   - Added use strict; to a few unlucky modules


1;
__END__


=head1 NAME

Data::All - Access to data in many formats from many places

=head1 SYNOPSIS 1 (short)

    use Data::All;
    
    #   Create an instance of Data::All for database data
    my $input = Data::All->new(path => '/some/file.csv', profile => 'csv');
    
    #   Open the connection. Nothing happens until you tell it to. 
    $input->open();
    
    #   $rec now contains an arrayref of hashrefs for the data defined in %db.
    #   collection() is a shortcut (see Synopsis 2)
    my $rec  = $input1->read();

    #   Convert $input to another format.
    #   NOTE: The hash reference here is different than the hash used by new()
    $input->convert({path => '/tmp/file.tab', profile => 'tab'}); 

    #   $rec is the same above   
    #   NOTE: The hash reference here is different than the hash used by new()
    my $rec = collection({'path' => '/some/file.csv', profile => 'csv'});
    
=head1 SYNOPSIS 2 (long)

    use Data::All;
    
    my $dsn1     = 'DBI:mysql:database=mysql;host=YOURHOST;';
    my $dsn2     = 'DBI:Pg:database=SOMEOTHERDB;host=YOURHOST;';
    my $query1   = 'SELECT `Host`, `User`, `Password` FROM user';
    my $query2   = 'INSERT INTO users (`Password`, `User`, `Host`) VALUES(?,?,?)';
    
    my %db1 = 
    (   path        => [$dsn1, 'user', 'pass', $query1],
        ioconf      => ['db', 'r' ]
    );
    
    #   Notice how the parameters can be sent as a well-ordered arrayref
    #   or as an explicit hashref. 
    my %db2 = 
    (   path        => [$dsn2, 'user', 'pass', $query2],
        ioconf      => { type => 'db', perms => 'w' },
        fields      => ['Password', 'User', 'Host']
    );
    
    #   This is an explicit csv format. This is the same as using 
    #   profile => 'csv'. NOTE: the 'w' is significant as it is passed to 
    #   IO::All so it knows how to properly open and lock the file. 
    my %file1 = 
    (
        path        => ['/tmp/', 'users.csv'],
        ioconf      => ['plain', 'rw'],
        format      => {
            type    => 'delim', 
            breack  => "\n", 
            delim   => ',', 
            quote   => '"', 
            escape  => '\\',
        }
    );
    
    #   The only significantly different here is with_original => 1.
    #   This tells Data::All to include the original record as a field 
    #   value. The field name is _ORIGINAL. This is useful for processing
    #   data when auditing the original source is required.         
    my %file2 = 
    (
        path        => '/tmp/users.fixed',
        ioconf      => {type=> 'plain', perms => 'w', with_original => 1],
        format      => { 
            type    => 'fixed', 
            break   => "\n", 
            lengths => [32,16,64]
        },
        fields      => ['pass','user','host']
    );
    
    #   Create an instance of Data::All for database data
    my $input1 = Data::All->new(%db1);
    
    $input1->open();    #   Open the connection.
    
    #   $rec now contains an arrayref of hashrefs for the data defined in %db.
    my $rec  = $input1->read();
    
    $input1->convert(\%db2);    #   Save the mysql data to a postgresql table
    $input1->convert(\%file1);  #   And also save it to a file
    
    my $input2 = Data::All->new(%file1);    #   Open the file we just created
    $input2->convert(\%file2);      #   And convert it to a fixed width format
    
=head1 DESCRIPTION

Similar to AnyData, but more suited towards converting data types 
from and to various sources rather than reading data and playing with it. It is
like an extension to IO::All which gives you access to data sources; Data::All
gives you access to data. 

Data::All is based on a few abstracted concepts. The line is a record and a 
group of records is a collection. This allows a common record storing concept
to be used across any number of data sources (delimited file, XML over a socket,
a database table, etc...). 

Supported formats: delimited and fixed.
Supported sources: local filesystem, database, socket (not heavily tested).

Note that currently conversion happens an entire collection at a time which 
would be an issue if you are dealing with large datasets. 

Data::All is a Spiffy module. 

=head1 TODO LIST

Current major development areas are the interface and format 
stability. Upcoming development are breadth of features (more formats, more
sources, ease of use, reliable subclassing, documentation/tests, and speed).

Misc:
   TODO: Create Data::All::Transport for taking care of converting formats
   TODO: Add ability to create temporary files
   TODO: Allow handling record fields with arrayrefs for anon / non-hash access
   TODO: Default values for fields (avoid undef db errors)
   TODO: Allow conversion to happen line by line.
   TODO: Allow modifying data in memory and saving it back to a file
   TODO: Consider using a standard internal structure, so every source is
         converted into this structure (hash, Stone?)
   TODO: Add SQL as a readable input and output
   TODO: Expose format functions to Data::All users so simple single record
         conversion can be thoroughly utilized.

=head1 STABILITY

This module is currently undergoing rapid development and there is much left to 
do. It is still in the alpha stage, so it is definitely not recommended for
production use. 

It has only been tested on Solaris 8 (SPARC64).

=head1 KNOWN BUGS

The record separator does not currently work properly as it is hardcoded 
to be newline (for delimited and fixed formats). 

A perm of rw hasn't been tested, but should work. 

The examples probably require a little tweaking to work properly.

=head1 SEE ALSO

IO::All, AnyData, Spiffy

=head1 AUTHOR

Delano Mandelbaum, E<lt>horrible<AT>murderer.caE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2004 by Delano Mandelbaum

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.3 or,
at your option, any later version of Perl 5 you may have available.


=cut