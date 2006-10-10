#!perl -w 

use Test::More tests => 2;
use File::Spec;

my $w = 0;
my $f = 0;

 SKIP: {
     skip "\$WNHOME not set",1 unless exists($ENV{'WNHOME'});
     $w = 1 if(ok(-e $ENV{'WNHOME'}, "Testing if \$WNHOME exists"));
}
 SKIP: {
     skip "\$FNHOME not set",1 unless exists($ENV{'FNHOME'});
     $f = 1 if(ok(-e $ENV{'FNHOME'}, "Testing if \$FNHOME exists"));
}

print "Bail out! \$WNHOME is not set.\n" if (! $w);
print "Bail out! \$FNHOME is not set.\n" if (! $f);



