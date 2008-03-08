package Data::FormValidator::Profile;

###############################################################################
# Required inclusions.
###############################################################################
use strict;
use warnings;

###############################################################################
# Version number.
###############################################################################
our $VERSION = '0.01';

###############################################################################
# Use the '_arrayify()' method from DFV.
###############################################################################
use Data::FormValidator;
*_arrayify = \&Data::FormValidator::_arrayify;

###############################################################################
# Subroutine:   new()
###############################################################################
# Creates a new DFV::Profile object, based on the given profile (which can be
# provided either as a HASH or a HASHREF).
###############################################################################
sub new {
    my $class = shift;
    my $self = {
        'profile' => (ref($_[0]) eq 'HASH') ? $_[0] : {@_},
        };
    bless $self, $class;
}

###############################################################################
# Subroutine:   profile()
###############################################################################
# Returns the actual profile, as a hash-ref.  You need to call this method when
# you want to send the profile through to 'Data::FormValidator' to do data
# validation.
###############################################################################
sub profile {
    my $self = shift;
    return $self->{'profile'};
}

###############################################################################
# Subroutine:   only(@fields)
# Parameters:   @fields     - List of fields to include
###############################################################################
# Reduces the profile so that it only contains information on the given list of
# '@fields'.
###############################################################################
sub only {
    my ($self, @fields) = @_;
    my %lookup = map { $_=>1 } @fields;
    $self->_update( sub { exists $lookup{$_[0]} } );
}

###############################################################################
# Subroutine:   remove(@fields)
# Parameters:   @fields     - List of fields to exclude
###############################################################################
# Removes any of the given '@fields' from the profile.
###############################################################################
sub remove {
    my ($self, @fields) = @_;
    my %lookup = map { $_=>1 } @fields;
    $self->_update( sub { not exists $lookup{$_[0]} } );
}

###############################################################################
# Subroutine:   _update($matcher)
# Parameters:   $matcher    - Field matching routine
###############################################################################
# Updates the profile so that it includes only those fields that return true
# from the given '$matcher' routine.
###############################################################################
sub _update {
    my ($self, $matcher) = @_;
    
    # Get the profile we're manipulating.
    my $profile = $self->profile();

    # list-based fields: required, optional
    foreach my $type (qw( required optional )) {
        if (exists $profile->{$type}) {
            $profile->{$type} = [
                grep { $matcher->($_) } _arrayify($profile->{$type})
            ];
        }
    }

    # hash-based fields: defaults, filters, constraints
    foreach my $type (qw( default field_filters constraints constraint_methods )) {
        if (exists $profile->{$type}) {
            $profile->{$type} = {
                map { $_ => $profile->{$type}{$_} }
                    grep { $matcher->($_) }
                    keys %{$profile->{$type}}
            };
        }
    }
}

1;

=head1 NAME

Data::FormValidator::Profile - Profile object for Data::FormValidator

=head1 SYNOPSIS

  use Data::FormValidator;
  use Data::FormValidator::Profile;

  # create a new DFV::Profile object
  $profile = Data::FormValidator::Profile->new( {
      optional  => [qw( this that )],
      required  => [qw( some other thing )],
      } );

  # reduce the profile to just a limited set of fields
  $profile->only( qw(this that) );

  # remove fields from the profile
  $profile->remove( qw(some other thing) );

  # use the profile to validate data
  $data = { ... };
  $res  = Data::FormValidator->check( $data, $profile->profile() );

=head1 DESCRIPTION

C<Data::FormValidator::Profile> provides an interface to help manage
C<Data::FormValidator> profiles.

I found that I was frequently using C<Data::FormValidator> profiles to help
define my DB constraints and validation rules, but that depending on the
context I was working in I may only be manipulating a small handful of the
fields at any given point.  Although I could query my DB layer to get the
default validation profile, I was really only concerned with the rules for two
or three fields.  Thus, C<Data::FormValidator::Profile>, to help make it easier
to trim profiles to include only certain sets of fields in the profile.

=head2 Limitations

All said, though, C<Data::FormValidator::Profile> has some limitations that you
need to be aware of.

=over

=item *

It B<only> removes fields from the following profile attributes:

  required
  optional
  defaults
  field_filters
  constraints
  constraint_methods

B<NO> effort is made to update dependencies, groups, require_some, or anything
based on a regexp match.  Yes, that does mean that this module is limited in
its usefulness if you've got really fancy C<Data::FormValidator> profiles.
That said, though, I'm not using anything that fancy, so it works for me.

=item *

In order to use the profile with C<Data::FormValidator>, you B<must> call
C<profile()> on it to get the actual underlying profile back as a HASHREF that
you can pass through to C<Data::FormValidator>.  C<Data::FormValidator> doesn't
accept any sort of blessed object for a profile, so you have to call this method
to access the underlying HASHREF for the profile.

=back

=head1 METHODS

=over

=item new()

Creates a new DFV::Profile object, based on the given profile (which can be
provided either as a HASH or a HASHREF). 

=item profile()

Returns the actual profile, as a hash-ref. You need to call this method
when you want to send the profile through to C<Data::FormValidator> to do
data validation. 

=item only(@fields)

Reduces the profile so that it only contains information on the given list
of C<@fields>. 

=item remove(@fields)

Removes any of the given C<@fields> from the profile. 

=item _update($matcher)

Updates the profile so that it includes only those fields that return true
from the given C<$matcher> routine. 

=back

=head1 AUTHOR

Graham TerMarsch (cpan@howlingfrog.com)

=head1 COPYRIGHT

Copyright (C) 2008, Graham TerMarsch.  All Rights Reserved.

This is free software; you can redistribute it and/or modify it under the same
terms as Perl itself.

=head1 SEE ALSO

L<Data::FormValidator>.

=cut
