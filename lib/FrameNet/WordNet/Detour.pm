package FrameNet::WordNet::Detour;
require Exporter;
our @ISA = qw(Exporter);
our $VERSION = 0.9;

#BEGIN {
#  use Exporter   ();
#  our ($VERSION, @ISA);
#  $VERSION     = 0.9;
#  @ISA         = qw(Exporter);
#};

use strict;
use warnings;
use Storable;
use Carp;
use XML::TreeBuilder;
use FrameNet::WordNet::Detour::Frame;
use FrameNet::WordNet::Detour::Data;
use WordNet::QueryData;
use WordNet::Similarity::path;

#my $SYNSET2FRAMES = "$Bin/$Script";
my $FNHOME = $ENV{'FNHOME'};
my $FNXML = "";
if (-e $FNHOME."/frXML/frames.xml") {
  $FNXML = $FNHOME."/frXML/frames.xml";
} else {
  $FNXML = $FNHOME."/xml/frames.xml";
};
my $TMP_PREFIX = "/tmp/".$ENV{'USER'}."-";


sub new
{
  my $class = shift;
  my $this = {};

  $class = ref $class || $class;

  $this->{'wn'} = shift;
  unless (defined $this->{wn}) {
    $this->{errorString} .= "\nError (${class}::new()) - ";
    $this->{errorString} .= "A WordNet::QueryData object is required.";
    $this->{error} = 2;
  };
  
  $this->{'sim'} = shift;
  unless (defined $this->{sim}) {
    $this->{errorString} .= "\nError (${class}::new()) - ";
    $this->{errorString} .= "A WordNet::Similarity:: object is required.";
    $this->{error} = 2;
  };

  bless $this, $class;

  $this->initialize;
  
  return $this;
}

sub initialize {
  my $self = shift;
  
  $self->{'cached'} = 1;
  $self->{'limited'} = 0;  
  $self->{'matched'} = 0;
  $self->{'verbosity'} = 0;
  $self->{'results'} = [];
  
  $self->{'resulthashname'} = ${TMP_PREFIX}."FrameNet-WordNet-Detour-".$VERSION."_".$self->{'limited'}.".dat";

}

sub query {
  my $self = shift;
  my $synset = shift;

  if ($synset =~ /^[\w\- ']+#[nva]#\d+$/i) {
    if (scalar($self->{'wn'}->querySense($synset,"syns")) == 0) {
      my $msg = "\'$synset\' not listed in WordNet";
      carp "$msg" if ($self->{'verbosity'});
      return FrameNet::WordNet::Detour::Data->new({},$synset,$msg);
    };
    return FrameNet::WordNet::Detour::Data->new($self->basicQuery($synset),$synset,'OK');
  }
  
  # if the query-word is underspecified (e.g. get#v),
  # we query each possible sense once, collect a list of results
  # and return it
    
  elsif ($synset =~ /^[\w\- ']+#[nva]$/i) {
    # my $results = [];
    my @senses = $self->{'wn'}->querySense($synset);
    if ((scalar @senses) == 0) {
      my $msg = "\'$synset\' not listed in WordNet";
      carp "$msg" if ($self->{'verbosity'});
      return FrameNet::WordNet::Detour::Data->new($self->basicQuery($synset),$synset,'OK');
    }
  }
  # if the query-word is underspecified (e.g. get#v),
  # we query each possible sense once, collect a list of results
  # and return it
  
  elsif ($synset =~ /^[\w\- ']+#[nva]$/i) {
    # my $results = [];
    my @senses = $self->{'wn'}->querySense($synset);
    if ((scalar @senses) == 0) {
      my $msg = "\'$synset\' not listed in WordNet";
      carp "$msg" if ($self->{'verbosity'});
      return FrameNet::WordNet::Detour::Data->new({},$synset,$msg);
    };
    return $self->query(\@senses);
  } 

  elsif (ref $synset eq "ARRAY") {
    my @r = ();
    foreach my $sense (@$synset) {
      push(@r, $self->query($sense));
    };
    return \@r;
  }
    else {
    my $msg = "Query (\'$synset\') not well-formed";
    carp $msg if ($self->{'verbosity'});
    #print STDERR $msg."\n"  if ($self->{'verbosity'});
    return FrameNet::WordNet::Detour::Data->new({},$synset, $msg);
  }
};

sub basicQuery {
  my ($self,$synset) = @_;
  
  print STDERR "\nQuerying: $synset ...\n" if ($self->{'verbosity'});

  if ($self->{'cached'}) {  
    my $KnownResults;
    if (-e $self->{'resulthashname'}) {
      $KnownResults = retrieve($self->{'resulthashname'});
    };
    return $KnownResults->{$synset} if (exists($KnownResults->{$synset}));
  };
  
  $self->{'similarities'} = {};
  $self->{'synset'} = $synset;
  my @tmp = split(/#/,$synset);
  $self->{'in_word'} = $tmp[0];
  
  $self->{'verbose'} = '';
  
  $self->{'result'}{'raw'} = $self->weight_frames($self->generate_candidate_frames($synset));
  $self->{'result'}{'sorted'} = $self->sort_by_weight;

  print STDERR "Best result(s): ".(join(' ',$self->best_frame))."\n" 
    if ($self->{'verbosity'});
  
  if ($self->{'cached'}) {
    my $KnownResults = retrieve($self->{'resulthashname'}) if (-e $self->{'resulthashname'});
    $KnownResults->{$synset} = $self->{'result'};
    store($KnownResults,$self->{'resulthashname'});
  };  
  
  return $self->{'result'};
};


sub cached {
  my $self = shift;
  $self->{'cached'} = 1;
};

sub uncached {
  my $self = shift;
  $self->{'cached'} = 0;
};

sub limited {
  my $self = shift;
  $self->{'limited'} = 1;
};

sub unlimited {
  my $self = shift;
  $self->{'limited'} = 0;
};

sub matched {
    my $self = shift;
    $self->{'matched'} = 1;
};

sub unmatched {
    my $self = shift;
    $self->{'matched'} = 0;
};

sub set_verbose {
  my $self = shift;
  $self->{'verbosity'} = 1;
};

sub unset_verbose {
  my $self = shift;
  $self->{'verbosity'} = 0;
}

sub set_debug {
    my $self = shift;
    $self->{'verbosity'} = 2;
};

sub generate_candidate_frames {
  # synset format: car#n#2...
  my ($self,$synset) = @_;

  my $pos = (split('#', $synset))[1];
  my $MatchingFrames;

  my %CandidateSynsets;
    
  if ($synset =~ /\d$/) {
    # first add input synset
    $CandidateSynsets{"$synset"} = 1;
  } else {
    # takes all Senses matching the given word and part-of-speech
    foreach my $sense ($self->{'wn'}->querySense($synset)) {
      $CandidateSynsets{"$sense"} = 1;
    }
  }
  
  # second collect hypernyms
  # initially self
  my @currentSynsets = ("$synset");
  
  
  # add hype syns for each synset member
  while (1) {
    my @newSynsets;
    if ($pos !~ /a/) {
      foreach my $synset (@currentSynsets) {
	push (@newSynsets,$self->{'wn'}->querySense($synset,'hype'));
      }
    };
    @currentSynsets = @newSynsets;      
    foreach my $newsynset (@newSynsets){
      $CandidateSynsets{lc("$newsynset")} = 1;    
    };
    
    # stop if no more hypernyms found
    if (! @newSynsets) {last};
  };
  
  # compute all members of input and hypernym synsets
  my %AllCandidates;
  
  foreach my $candidatesynset (keys %CandidateSynsets) {
    
    # synonyms and antonyms of candidate synset
    foreach my $tmpsynset ($self->{'wn'}->querySense("$candidatesynset",'syns'),
			   $self->{'wn'}->queryWord("$candidatesynset",'ants')) {
      $AllCandidates{lc("$tmpsynset")} = 1;
    };
  };
  
  
  print STDERR "Synsets considered: " if ($self->{'verbosity'});
  print STDERR "\n" if ($self->{'verbosity'} gt 1);
  # lookup all candidates
  foreach my $candidatesynset (keys %AllCandidates) {
    $MatchingFrames = mergeResultHashes($MatchingFrames,$self->lookup_synset($candidatesynset));
    if ($candidatesynset =~ / /i) {
      my $synset_with_underscores = $candidatesynset;
      $synset_with_underscores =~ s/ /_/ig;
      $MatchingFrames = mergeResultHashes($MatchingFrames,$self->lookup_synset($synset_with_underscores));
    } elsif ($candidatesynset =~ /_/i) {
      my $synset_with_spaces = $candidatesynset;
      $synset_with_spaces =~ s/_/ /ig;
      $MatchingFrames = mergeResultHashes($MatchingFrames,$self->lookup_synset($synset_with_spaces));
    }
    
  };
  
  $self->{'numberOfSynsets'} = scalar (keys %AllCandidates);
  
  print STDERR "\n" if ($self->{'verbosity'});
  
  return $MatchingFrames;
};

sub lookup_synset {
  my ($self,$synset) = @_;
  my $MatchingFrames;

  my $synsetprint = $synset;
  if ($synsetprint =~ / /gi) {
      $synsetprint = "\'$synsetprint\'";
  }




  ### Retrieve /tmp/$usr-lu2frame-hash.pl if exists and up-to-date; else create it###
  # nr: used perl-function stat() instead of linux-program for compatibility-reasons
  if (! -e "${TMP_PREFIX}lu2frames-hash.pl" || ((stat("${TMP_PREFIX}lu2frames-hash.pl"))[9] < (stat($FNXML))[9])) {
      $self->make_lu2frames_hash();
  }; #else {
  my %TmpHash = %{retrieve("${TMP_PREFIX}lu2frames-hash.pl")};
  my $Lu2Frames = $TmpHash{'lu2frames'};
  my $FrameNames = $TmpHash{'frameNames'};

  my ($string,$pos,$sense) = split('#',$synset);
				   
  # LIMITED SYSTEM: skip input word
  if (! $self->{'limited'} || $string ne $self->{'in_word'}) {
      $self->{'relatedness'}{"$synset"} = 0;
      if ($pos ne "a") {
	  $self->{'relatedness'}{"$synset"} = 
	      $self->{'sim'}->getRelatedness($synset,$self->{'synset'});
      } else {
	  $self->{'relatedness'}{"$synset"} = 1;
      }
      my ($error, $errorString) = $self->{'sim'}->getError();
      print STDERR "$errorString\n" if($error && $self->{'verbosity'});
      

      print STDERR $synsetprint."(".(int(($self->{'relatedness'}{"$synset"}*1000)+.5)/1000).") "
	if ($self->{'verbosity'});
 #     print uc("$string\.$pos")."\n";
      # Is there a LU?
      if (exists $Lu2Frames->{lc("$string\.$pos")}) {
	  
	  foreach my $_frameName (@{$Lu2Frames->{lc("$string\.$pos")}}) {
	      $MatchingFrames->{'lu'}->{$_frameName}->{"$synset"} = 1;
	     # print uc("$string\.$pos")." --- ".uc($_frameName)."\n";
	  };
      } elsif ($self->{'matched'}) {
	  
	  
	  # is there a matching frame name?
	  foreach my $frameName (keys %{$FrameNames}) {
	      my $alpha_string = $string;
	      my $alpha_frameName = lc($frameName);
	      
	      # remove all non-word chars (including _) in alpha_
	      $alpha_string =~ s/[\W,_]//g;
	      $alpha_frameName =~ s/[\W,_]//g;
	      
	  # $alpha_string is prefix or suffix of $alpha_frameName or the other way round
	  if ((substr($alpha_frameName,-length($alpha_string),length($alpha_string)) eq $alpha_string) ||
	      (substr($alpha_frameName,0,length($alpha_string)) eq $alpha_string) ||
	      (substr($alpha_string,-length($alpha_frameName),length($alpha_frameName)) eq $alpha_frameName) ||
	      (substr($alpha_string,0,length($alpha_frameName)) eq $alpha_frameName)
	     ) {
	    $MatchingFrames->{'match'}->{$frameName}->{"$synset"} = 1;
	  };
	};
      };
    };
#   };

  if ($self->{'verbosity'} gt 1) {
      print STDERR "\n  evokes(lu): [".
	  join(' ',keys(%{$MatchingFrames->{'lu'}})).
	  "]\n";
      print STDERR "  evokes(match): [".
	  join(' ',keys(%{$MatchingFrames->{'match'}})).
	  "]\n" if ($self->{'matched'}); 
  };
  return $MatchingFrames;
};


sub weight_frames {
  my ($self,$MatchingFrames) = @_;
  # $self->clog(2, "Weighting Frames ...\n");
  my $AllResult;



  my $SpreadingFactor;

  foreach my $reason ('lu','match') {
    foreach my $frameName (keys %{$MatchingFrames->{$reason}}) {
      foreach my $fee (keys %{$MatchingFrames->{$reason}->{$frameName}}) {  
	$SpreadingFactor->{$fee} += 1;
      };
    };
  };
    

  
  print STDERR "All Frames: " if ($self->{'verbosity'});

  foreach my $reason ('lu','match') {
    foreach my $frameName (keys %{$MatchingFrames->{$reason}}) {
      
      $AllResult->{$frameName} = 
	FrameNet::WordNet::Detour::Frame->new($frameName);
      
      foreach my $fee (keys %{$MatchingFrames->{$reason}->{$frameName}}) {

	$AllResult->{$frameName}->add_fee($fee);
	
	my $weight = $self->{'relatedness'}{"$fee"};
	
	$AllResult->{$frameName}->add_sim($weight);

	# cheat for adjectives!!!
	if (!$weight) {$weight = 0.5};
	
	# Square of distance
	$weight = $weight * $weight;
	
	# Boost for LU
	# if ($reason eq 'lu') {$weight *= 1.5};
	
	# divided by Spreading Factor
	$weight /= $SpreadingFactor->{$fee};
	
	# $AllResult->{$frameName}->{'weight'} += $weight;
	$AllResult->{$frameName}->add_weight($weight);
      };

      $AllResult->{$frameName}->set_weight($AllResult->{$frameName}->get_weight() / $self->{numberOfSynsets});

      print STDERR $frameName.
	"(".(int((($AllResult->{$frameName}->{'weight'})*1000)+.5)/1000).") "
	  if ($self->{'verbosity'});
    };
  };
  
  print STDERR "\n" if ($self->{'verbosity'});


  
  return $AllResult;
};


sub sort_by_weight {
   my ($self) = @_; 
  
  my $AllResult = $self->{'result'}->{'raw'};

  my $ResultsByWeight;
  foreach my $frame (keys %$AllResult) {
    my $weight = $AllResult->{$frame}->{'weight'};
    #$weight = int(($weight*1000)+.5)/1000;
    $ResultsByWeight->{$weight}->{$frame} = $AllResult->{$frame};
  };
   
  return $ResultsByWeight;
};


sub best_frame {
  my $self = shift;
  my $f = $self->n_results(1);
  return keys %$f;
};

sub n_results {
  my ($self,$number_results) = @_;
  
  my $ResultsByWeight = $self->sort_by_weight();

  my $ResultHash;

  my $result_counter = 1;
  
  foreach my $weight (reverse(sort(keys %$ResultsByWeight))) {
    if ($result_counter <= $number_results) {
      foreach my $frame (keys %{$ResultsByWeight->{$weight}}) {
	$ResultHash->{$frame} = $ResultsByWeight->{$weight}->{$frame};
      };
    };
    $result_counter++;
  };
  return $ResultHash;
};


sub make_lu2frames_hash {
  my $self = shift;
  print STDERR "\nGenerating LU index may take a while...\n" if ($self->{'verbosity'});

  my $file = $FNXML;

  my $tree = XML::TreeBuilder->new();
  $tree->parse_file($file);
    
  my $FrameNames;
  my $Lu2Frames;
  
  foreach my $frame ($tree->find_by_tag_name('frame')){
    $FrameNames->{lc($frame->attr('name'))} = 1;
    foreach my $lu ($frame->find_by_tag_name('lexunit')) {
      push(@{$Lu2Frames->{lc($lu->attr('name'))}},$frame->attr('name'));
    };
  };
  
  store ({'lu2frames'=>$Lu2Frames, 'frameNames'=>$FrameNames}, "${TMP_PREFIX}lu2frames-hash.pl");
};


sub mergeResultHashes {
  my ($H1,$H2) = @_;
  foreach my $reason ('lu','match') {
      foreach my $frameName (keys %{$H2->{$reason}}) {
	foreach my $fee (keys %{$H2->{$reason}->{$frameName}}) {
	  if (exists $H1->{$reason}->{$frameName}->{$fee}) {
	    $H1->{$reason}->{$frameName}->{$fee} += $H2->{$reason}->{$frameName}->{$fee}
	  } else {
	    $H1->{$reason}->{$frameName}->{$fee} = $H2->{$reason}->{$frameName}->{$fee}
	  };
	};
      };
    };
  return $H1;
};


sub toHash {
  my $list = shift;
  my $hash = {};
  foreach my $elem (@$list) {
    $hash->{$elem} = 1;
  };
  return $hash;
};

1;


__END__


## DOCUMENTATION ##



=head1 NAME

FrameNet::WordNet::Detour - a WordNet2FrameNet Detour.

=head1 SYNOPSIS

  use FrameNet::WordNet::Detour;

  my $wn = WordNet::QueryData->new($WNSEARCHDIR);
  my $sim = WordNet::Similarity::path->new ($wn);
  my $detour = FrameNet::WordNet::Detour->new($wn,$sim);

  my $result = $detour->query($synset);

  if ($result->isOK) {
    print "Beste Frames: \n"
    print join(' ', $result->get_best_framenames);
    print "Alle Frames: \n"
    print join(' ', $result->get_all_framenames);
    foreach my $frame ($result->get_all_frames) {
       print $frame->get_name.": ";
       print $frame->get_weight."\n";
    }
  } else {
    print $result->get_message."\n";
  }

=head1 DESCRIPTION

=head1 FUNCTIONS

=over 4

=item new( $wn, $sim )

Blesses a new Detour-object. C<$wn> has to be an object of type L<WordNet::QueryData|WordNet::QueryData>, C<$sim> has to be an object of type L<WordNet::similarity::path|WordNet::similarity::path>.

Will call implicitly the method C<initialize()>.

=item query ( $string )

The query-function. Returns a L<FrameNet::WordNet::Detour::Data|FrameNet::WordNet::Detour::Data>-object containing the result. C<$string> can be either one synset (e.g. get#v#1) or a word and its part-of-speech (e.g. get#v).

If the string one asks for is not recorded in WordNet or if the query-string is not wellformed, then a Data-object will be returned also, but it contains no data, and its method L<isOK()|FrameNet::WordNet::Detour::Data/isOK()> will return a false value. 

A more detailed description of the error can be accessed via L<getMessage()|FrameNet::WordNet::Detour::Data/getMessage()> and will be in verbose output if it is enabled (see C<set_verbose()> for further information). 

The query-string can be given in two forms:

 get#v#1 -- a fully specified synset or
 get#v -- a word and its part-of-speech

In either way, the delimiter has to be '#'.

=item listQuery ( $list )

Returns a reference to a list of Data-objects. These are the results of a query for each single synset in the given C<$list> (which has to be given as reference).

For the specification of each single synset, the same rules as in the function L</query> apply.

Internally, this method will be called with all synsets for this word in a list from within C<query()> if one gives a query string of the second form.

B<For internal use only.>

=item basicQuery ( $synset )

Queries one single, fully specified Synset, and returns the result as a non-blessed reference to a hash. 

B<For internal use only.>

=item cached ( )

=item uncached ( )

Enables or disables the caching. 

If caching is enabled, all results are stored in a binary file. The file is located in /tmp (or an equivalent). The results are devided into the limited and the unlimited ones and stored in different files. 

Default: Cached. 

=item limited ( )

=item unlimited ( )

Enables or Disables the limited-mode. 

In the limited mode, the query-synset itself will not be asked for in FrameNet. Normally, there should be no need to use the limited mode, since one could easily get the frames to a synset, when it is specified as lexical unit in FrameNet. In this case, there is no need for this whole script either.  

Default: Unlimited.

=item set_verbose ( )

=item set_debug ( )

=item unset_verbose ( )

As the names allready tell, with these methods, one can set different modes of output. If the script is in verbose-mode, some information during the work is printed out. If the script runs in debug-mode, information as much as possible will be printed out. With C<unset_verbose()>, no information at all will be printed.

All output goes to STDERR. 

Default: No verbose, no debug. 

=item initialize ( )

This method initializes the object. I.e., it sets several values to its defaults and it empties the result-array. The default values are:

=over 4

=item * cached: 1

=item * limited: 0

=item * verbosity: 0

=back

=back

=head1 BUGS

=for text Please report bugs to reiter@cpan.org.

=for html <p>Please report bugs to <a href="mailto:reiter@cpan.org">reiter@cpan.org</a>.</p>

=head1 COPYRIGHT

Copyright 2005 Aljoscha Burchardt and Nils Reiter. All rights reserved.

This module is free software; you can redistribute it and/or modify it under the same terms as Perl itself.

=head1 SEE ALSO

L<WordNet::QueryData>

L<WordNet::similarity>

L<FrameNet::WordNet::Detour::Data>

L<FrameNet::WordNet::Detour::Frame>

=cut





