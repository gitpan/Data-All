package IO::All::MLDBM;
use strict;
use warnings;
use IO::All::DBM '-Base';

field _serializer => 'Data::Dumper';

sub mldbm {
    bless $self, __PACKAGE__;    
    my ($serializer) = grep { /^(Storable|Data::Dumper|FreezeThaw)$/ } @_;
    $self->_serializer($serializer) if defined $serializer;
    my @dbm_list = grep { not /^(Storable|Data::Dumper|FreezeThaw)$/ } @_;
    $self->_dbm_list([@dbm_list]);
    return $self;
}

sub tie_dbm {
    my $filename = $self->name;
    my $dbm_class = $self->_dbm_class;
    my $serializer = $self->_serializer;
    eval "use MLDBM qw($dbm_class $serializer)";
    $self->throw("Can't open '$filename' as MLDBM:\n$@") if $@;
    my $hash;
    tie %$hash, 'MLDBM', $filename, $self->mode, $self->perms, 
        @{$self->_dbm_extra}
      or $self->throw("Can't open '$filename' as MLDBM file:\n$!");
    $self->tied_file($hash);
}

1;

__DATA__

=head1 NAME 

IO::All::MLDBM - MLDBM Support for IO::All

=head1 SYNOPSIS

See L<IO::All>.

=head1 DESCRIPTION

=head1 AUTHOR

Brian Ingerson <INGY@cpan.org>

=head1 COPYRIGHT

Copyright (c) 2004. Brian Ingerson. All rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

See http://www.perl.com/perl/misc/Artistic.html

=cut
