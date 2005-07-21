#!perl 

use Test::Simple tests => 3;

use FrameNet::WordNet::Detour;
use FrameNet::WordNet::Detour::Data;
use FrameNet::WordNet::Detour::Frame;

#BEGIN {
#	use_ok( 'FrameNet::WordNet::Detour' );
#	use_ok( 'FrameNet::WordNet::Detour::Data' );
#	use_ok( 'FrameNet::WordNet::Detour::Frame' );
#}



my $wn = WordNet::QueryData->new($ENV{'WNHOME'});
my $sim = WordNet::Similarity::path->new($wn);
my $detour = FrameNet::WordNet::Detour->new($wn,$sim);
$detour->unset_verbose;

ok($ENV{'WNHOME'} ne "", "Testing \$WNHOME");
ok($ENV{'FNHOME'} ne "", "Testing \$FNHOME");
ok($detour->query("get#v#1")->isOK, "Test run with get#v#1");
