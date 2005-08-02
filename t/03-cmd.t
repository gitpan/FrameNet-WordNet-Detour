#!perl

use Test::Simple tests => 1;


my $t1 = `blib/script/Detour get#v#1`;

ok($t1 =~ /Getting;/);
