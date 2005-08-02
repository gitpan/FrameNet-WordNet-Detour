#!perl -T

use Test::Simple tests => 1;

use FrameNet::WordNet::Detour;
use FrameNet::WordNet::Detour::Data;
use FrameNet::WordNet::Detour::Frame;

my $detour = FrameNet::WordNet::Detour->new;

ok(ref $detour eq "FrameNet::WordNet::Detour");
