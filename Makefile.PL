use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'FrameNet::WordNet::Detour',
    AUTHOR              => 'Nils Reiter <reiter@cpan.org>',
    VERSION_FROM        => 'lib/FrameNet/WordNet/Detour.pm',
    ABSTRACT_FROM       => 'lib/FrameNet/WordNet/Detour.pm',
    PL_FILES            => {},
    PREREQ_PM => {
        'Test::More' => 0,
	'WordNet::QueryData' => 1.37,
	'WordNet::Similarity::path' => 0.10,
	'XML::TreeBuilder' => 3.09,
	'Getopt::Long' => 2.34,
	'Pod::Usage' => 0,
    },
    EXE_FILES => [ 'script/Detour' ],
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'FrameNet-WordNet-Detour-*' },
);
