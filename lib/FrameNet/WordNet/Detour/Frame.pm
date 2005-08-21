package FrameNet::WordNet::Detour::Frame;

require Exporter;
our @ISA = qw(Exporter);
our $VERSION = "0.95";

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
  return ($rounded? int(($self->{'weight'} * 1000)+0.5)/1000 :$self->{'weight'});
};

sub get_name {
  my $self = shift;
  return $self->{'frame'};
};

sub get_fees {
  my $self = shift;
  return $self->{'fees'};
};

1;


__END__


## DOCUMENTATION ##

=head1 NAME

FrameNet::WordNet::Detour::Frame - A class representing one single frame.

=head1 SYNOPSIS

  my $frame = {$result->get_best_frames}->[0];

  print "Frame ".$frame->get_name."\n";
  print "Weight ".$frame->get_weight."\n";

=head1 BUGS

Please report bugs to L<mailto:reiter@cpan.org>.

=head1 COPYRIGHT

Copyright 2005 Aljoscha Burchardt and Nils Reiter. All rights reserved.

This module is free software; you can redistribute it and/or modify it under the same terms as Perl itself.

=cut
