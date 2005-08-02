#!perl

use Test::Simple tests => 4;

use FrameNet::WordNet::Detour;
use FrameNet::WordNet::Detour::Data;
use FrameNet::WordNet::Detour::Frame;

my $detour = FrameNet::WordNet::Detour->new;

ok($detour->query("get#v#1")->isOK);
ok(! $detour->query("get#")->isOK);
my @l = $detour->query("get#v#7")->get_best_framenames;
ok($l[1] eq "Feeling");
ok(ref $detour->query("get#v") eq "ARRAY");
