package FrameNet::WordNet::Detour::Frame;

require Exporter;
our @ISA = qw(Exporter);
our $VERSION = "0.98";

use strict;
use warnings;
use Class::MethodMaker
  [ new => 'new',
    scalar => [ { '*_reset' => undef,
		  '*_isset' => undef,
		  '*_clear' => undef }, qw / name weight / ],
    array => [ { '*_push' => '*_add',
		 '*_pop' => undef,
		 '*_shift' => undef,
		 '*_unshift' => undef,
		 '*_set' => undef } , qw / fees sims / ],
  ];

sub add_weight {
  my $self = shift;
  my $w = shift;
  $self->{'weight'} += $w;
};

1;


__END__


## DOCUMENTATION ##

=head1 NAME

FrameNet::WordNet::Detour::Frame - A class representing one single frame.

=head1 SYNOPSIS

  my $frame = {$result->get_best_frames}->[0];

  print "Frame ".$frame->name."\n";
  print "Weight ".$frame->weight."\n";
  print "Fees: ".join(",", @{$frame->fees});

=head1 METHODS

Note: Some of the methods allow writing of properties. This is only used during the creation of the module and should not be used and needed at all.

=over

=item new

=item name

If an argument is provided, the name of the frame is set to that value.  The method returns the name (after assignment to a provided value, if appropriate).


=item weight

Same as C<name>, except that it works for the weight instead of the name.

=item fees

Several Uses: If called without arguments, it returns the list of frame evoking elements in list context and a reference to that list in scalar context. Can also be called with an argument, that list B<replaces> the current value.

=item sims

Same as C<fees>, except that it works on the list of similarities of the fees.

=back

=head1 BUGS

Please report bugs to L<mailto:reiter@cpan.org>.

=head1 COPYRIGHT

Copyright 2005 Aljoscha Burchardt and Nils Reiter. All rights reserved.

This module is free software; you can redistribute it and/or modify it under the same terms as Perl itself.

=cut
