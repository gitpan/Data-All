use 5.006;
use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    NAME              => 'Data::All',
    VERSION_FROM      => 'lib/Data/All.pm', # finds $VERSION
    PREREQ_PM         => 
    {
	'IO::All' => undef,
	'Spiffy'  => undef,
	'Data::Dumper' => undef,
	'Text::ParseWords' => undef
    }, 
    ($] >= 5.005 ?     ## Add these new keywords supported since 5.005
      (ABSTRACT_FROM  => 'lib/Data/All.pm', # retrieve abstract from module
       AUTHOR         => 'Delano Mandelbaum <horrible <AT> muderer.ca>') : ()),
);