package FrameNet::WordNet::Detour::Data;

require Exporter;
our @ISA = qw(Exporter);
our $VERSION = "0.92";

use strict;
use warnings;

sub new {
  my $class = shift;
  my $this = {};
  
  bless($this, $class);
  
  $this->{'s2f-result'} = shift;
  $this->{'raw'} = $this->{'s2f-result'}{'raw'};
  $this->{'sorted'} = $this->{'s2f-result'}{'sorted'};
  $this->{'query'} = shift;
  $this->{'message'} = shift || '';

  return $this;
};

# Checks, wether the query returned some useful results or not. 
# If not, one should check the error message via &get_message. 
# Could be better, by checking deeper in the data structure,
# if there is a 'Frame'-Object.
sub isOK {
  my $self = shift;
  return 1 if ($self->{'message'} eq 'OK');
  return 0;
};

sub getMessage {
  my $self = shift;
  return $self->{'message'};
};

sub get_fees {
  my $self = shift;
  my $n = 0;
  my $frame = shift;
  return @{$self->{'raw'}->{$frame}->{'fees'}};
};

sub get_similarities {
  my $self = shift;
  my $frame = shift;
  my $n = shift || 0;
  return @{$self->{'raw'}->{$frame}->{'similarities'}};
};

sub get_weight {
  my $self = shift;
  my $frame = shift;

  return $self->{'raw'}->{$frame}->{'weight'};
};


# not working
sub get_delta {
  my $self = shift;
  my $frame = shift;
  

  my $w0 = $self->{'raw'}->{$frame}->{'weight'};
  my $w1 = 0;
  my @weights = ( sort { $a <=> $b } (keys %{$self->{'sorted'}}));



  for(my $i = 0; $i < scalar @weights; $i++) {
    $w1 = $weights[$i+1] if ($w0 == $weights[$i] && 
			     exists($weights[$i+1]));
  };
  return int((($w0 - $w1)*1000)+0.5)/1000;
};

sub get_number_of_results {
  my $self = shift;
  my $n = shift || 0;
  return scalar (keys %{$self->{'raw'}});
};

# Returns a reference to an array containing the arg1 
# best frames (as Frame-Objects). Frames are sorted according
# to their weight.
# If arg1 is not given, the best frame will be returned.
# Works always on the first (e.g. 0th) synset.
sub get_best_frames {
  my $self = shift;
  my $n = 0;
  my $m = shift || 1;

  my $ResultsByWeight = $self->{'sorted'};

  my $ResultList = [];

  my $result_counter = 1;
  
  foreach my $weight (reverse(sort(keys %$ResultsByWeight))) {
    if ($result_counter <= $m) {
      foreach my $frame (keys %{$ResultsByWeight->{$weight}}) {
	push (@$ResultList, $ResultsByWeight->{$weight}->{$frame});
      };
    };
    $result_counter++;
  };
  return $ResultList;
};

# WORKS
sub get_best_framenames {
  my $self = shift;
  my $m = shift || 1;
  my $frames = $self->get_best_frames($m);
  return map($_->get_name, @$frames);
};

# Returns a list of all found frames.
sub get_all_framenames ($) {
  my $self = shift;
  my $tmp = {};
  foreach my $res (@{$self->{'raw'}}) {
    foreach my $frame (keys %$res) {
      $tmp->{$frame} = 1;
    }
  }
  return (keys %$tmp);
};

sub get_all_frames {
  my $self = shift;
  my $ResultsByWeight = $self->{'sorted'};
  my $ResultList = [];

  foreach my $weight (reverse(sort(keys %$ResultsByWeight))) {
    foreach my $frame (keys %{$ResultsByWeight->{$weight}}) {
      push (@$ResultList, $ResultsByWeight->{$weight}->{$frame});
    };
  };
  return $ResultList;
};

1;


__END__

## DOCUMENTATION ##

=head1 NAME

FrameNet::WordNet::Detour::Data - A class representing the results of the Detour.

=head1 SYNOPSIS

  use FrameNet::WordNet::Detour;

  my $wn = WordNet::QueryData->new($WNSEARCHDIR);
  my $sim = WordNet::Similarity::path->new ($wn);
  my $detour = FrameNet::WordNet::Detour->new($wn,$sim);

  my $result = $detour->query($synset);

  $result->isOK;       # Returns whether there were problems in the run
  $result->getMessage; # Returns 'Ok' or an error message

  # All frames are returned as lists of 
  # L<FrameNet::WordNet::Detour::Frame> objects


  $result->get_best_frames; # Returns the frames 
                            # with the highest weight
  $result->get_best_frames(3); # Returns the frames
                               # with the three highest weights
  $result->get_all_frames; # Returns all resulting frames


  $result->get_best_framenames;    # Returns the names
                                   # of the highest weighted frames
  $result->get_best_framenames(3); # Returns the names of the frames
                                   # with the three highest weights
  $result->get_all_framenames;     # Returns the names of all frames.

=head1 BUGS

Please report bugs to L<mailto:reiter@cpan.org>.

=head1 COPYRIGHT

Copyright 2005 Aljoscha Burchardt and Nils Reiter. All rights reserved.

This module is free software; you can redistribute it and/or modify it under the same terms as Perl itself.

=cut
