#!perl -w 


use Test::More tests => 4;
use File::Spec;

isnt($ENV{'WNHOME'}, "", "Testing if \$WNHOME is set");
isnt($ENV{'FNHOME'}, "", "Testing if \$FNHOME is set");
SKIP: {
  skip "\$WNHOME not set",1 unless $ENV{'WNHOME'} ne "";
  ok(-e $ENV{'WNHOME'}, "Testing if \$WNHOME exists");
}
SKIP: {
  skip "\$FNHOME not set",1 unless $ENV{'FNHOME'} ne "";
  ok(-e $ENV{'FNHOME'}, "Testing if \$FNHOME exists");
}
