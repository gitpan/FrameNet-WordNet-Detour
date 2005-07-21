package FrameNet::WordNet::Detour::Data;

BEGIN {
  use Exporter   ();
  our ($VERSION, @ISA);
  $VERSION     = 0.9;
  @ISA         = qw(Exporter);
};

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

Synset2frames::Data - A Class to represent the results of Synset2frames.


=head1 SYNOPSIS

  use Synset2frames::Data;

=head1 DESCRIPTION

=head1 METHODS

=over 4

=item isOK ( )

Returns a true value if everything went fine. If some problems occured in the process, it returns a false value.

=back

=cut
