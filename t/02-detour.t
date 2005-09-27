#!perl

use Test::Simple tests => 6;

use FrameNet::WordNet::Detour;
use FrameNet::WordNet::Detour::Data;
use FrameNet::WordNet::Detour::Frame;

my $detour = FrameNet::WordNet::Detour->new;
$detour->unlimited;
$detour->uncached;

ok($detour->query("get#v#1")->isOK);
ok(! $detour->query("get#")->isOK);
my @l = @{$detour->query("get#v#7")->get_best_framenames};
ok(@l > 0);
ok($l[1] eq "Feeling");
ok(ref $detour->query("drink#v") eq "ARRAY");
ok($detour->query("get#v#1")->get_query eq "get#v#1");
