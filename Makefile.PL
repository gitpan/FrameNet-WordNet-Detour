use strict;
use warnings;
use ExtUtils::MakeMaker;
use File::Spec;

my $VCACHE = 0.91;
my $hashfilename =  File::Spec->catfile((File::Spec->tmpdir),
					(defined $ENV{'USER'}?$ENV{'USER'}:'user').'-FrameNet-WordNet-Detour-'.$VCACHE.'-luhash.dat');

WriteMakefile(
	      NAME                => 'FrameNet::WordNet::Detour',
	      AUTHOR              => 'Nils Reiter <reiter@cpan.org>',
	      VERSION_FROM        => 'lib/FrameNet/WordNet/Detour.pm',
	      ABSTRACT_FROM       => 'lib/FrameNet/WordNet/Detour.pm',
	      PL_FILES            => 

	      { 'script/customize.PL script/detour.proto' => 'script/detour',
	        'script/make-luhash.PL' => $hashfilename,
	        't/00-load.t.PL' => 't/00-load.t' },

	      PREREQ_PM => 
	      { 'Test::More' => 0,
		'WordNet::QueryData' => 1.37,
		'WordNet::Similarity::path' => 0.10,
		'XML::TreeBuilder' => 3.09,
		'Getopt::Long' => 2.34,
		'Pod::Usage' => 1.00,
		'File::Spec' => 0.86,
		'Class::MethodMaker' => 2.00 },

	      EXE_FILES => 
	      [ 'script/detour' ],

	      dist => 
	      { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },

	      clean => 
	      { FILES => 'FrameNet-WordNet-Detour-*' },

	      realclean =>
	      { FILES => '*~ blib' }
	     );
