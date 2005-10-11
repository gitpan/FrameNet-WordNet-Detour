use Config;

# customize script
# Copyright 2005 Nils Reiter. All rights reserved.
#
# This script is free software; 
# you can redistribute it and/or modify it under 
# the same terms as Perl itself.
#
# see the file README for informations how to use this

my $in = shift;
my $out = shift;

customize($out, $in);

sub customize {
  my $outfile = shift;
  my $protofile = shift;
  my $props = {};

  open IN, $protofile;
  open OUT, ">$outfile" or die "Can't create $outfile: $!"; 
  print OUT $Config{startperl}, " -w \n";  
  
  while(<IN>) {
    # Found customization information that is used in the following
    if (s/#CUSTOM_BEGIN#(\w+)#([^#]+)#CUSTOM_END#//) {
      #print STDERR "Property $1 registered\n";
      $props->{$1}->{code} = $2;
      my $p = $1;
      $props->{$p}->{value} = eval $props->{$p}->{code};
      $props->{$p}->{re_line} = "#".$p."_BEGIN#.*#".$p."_END#";
      $props->{$p}->{re_single} = "#".$p."_BEGIN#|#".$p."_END#";
    }
    # Each line is searched for each propery
    # Not tested with a lot of properties
    foreach my $p (keys %$props) {
      if (/$props->{$p}->{re_line}/) {
	s/$props->{$p}->{re_single}//g if ($props->{$p}->{value});
	s/$props->{$p}->{re_line}\n//g if (! $props->{$p}->{value}); 
      }
    };
    print OUT $_;
  }
  close IN;
  close OUT;
};
