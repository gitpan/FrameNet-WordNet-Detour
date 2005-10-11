use Config;
use File::Spec;

my $fname = shift;
my $hashfilename =  File::Spec->
  catfile((File::Spec->tmpdir),
	  (defined $ENV{'USER'}?
	   $ENV{'USER'}:
	   'user').
	  '-FrameNet-WordNet-Detour-0.91-luhash.dat');

open OUT, ">$fname" or die "Can't create 00-load.t: $!"; 
chmod(0755, "$fname"); 

print OUT $Config{startperl}, " -w \n"; 

print OUT q{

use Test::More tests => 5;
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

};

print OUT "\nok(-e \"$hashfilename\", \"Testing if LU hash was installed correctly\")\n";
