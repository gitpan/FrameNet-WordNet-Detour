package FrameNet::WordNet::Detour::Frame;

require Exporter;
our @ISA = qw(Exporter);
our $VERSION = "0.91";

use strict;
use warnings;

sub new {
  my $class = shift;
  my $this = {};
  bless($this, $class);
  $this->{'frame'} = shift;
  return $this;
};

sub add_fee {
  my $self = shift;
  my $fee = shift;
  push(@{$self->{'fees'}},$fee);
};

sub add_sim {
  my $self = shift;
  my $weight = shift;
  push(@{$self->{'similarities'}},$weight);
};

sub add_weight {
  my $self = shift;
  my $w = shift;
  $self->{'weight'} += $w;
};

sub set_weight {
  my $self = shift;
  my $w = shift;
  $self->{'weight'} = $w;
};

sub get_weight {
  my $self = shift;
  my $rounded = shift || 0;
  return ($rounded? int(($self->{'weight'}*1000)+.5)/1000 :$self->{'weight'});
};

sub get_name {
  my $self = shift;
  return $self->{'frame'};
};

1;


__END__


## DOCUMENTATION ##

=head1 NAME

Frame - A class that represents one single resulting frame from the Detour.
