#!perl -T

use Test::More tests => 1;

use FrameNet::WordNet::Detour;
use FrameNet::WordNet::Detour::Data;
use FrameNet::WordNet::Detour::Frame;

my $detour = FrameNet::WordNet::Detour->new;

is(ref $detour,"FrameNet::WordNet::Detour", 'Testing if Detour loads');
