#!perl -T

use Test::Simple tests => 3;


ok($ENV{'WNHOME'} ne "", "Testing \$WNHOME");
ok($ENV{'FNHOME'} ne "", "Testing \$FNHOME");
ok(-e "/tmp", "Testing /tmp");
