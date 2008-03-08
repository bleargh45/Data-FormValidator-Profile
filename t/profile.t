use strict;
use warnings;
use Test::More tests => 15;
BEGIN {
    use_ok( 'Data::FormValidator::Profile' );
}

###############################################################################
# Instantiation; hash
instantiation_via_hash: {
    my %profile = (
        required    => [qw(this that)],
        optional    => [qw(other thing)],
        field_filters => {
            this    => ['trim', 'digit'],
            },
        );
    my $object = Data::FormValidator::Profile->new( %profile );
    isa_ok $object, 'Data::FormValidator::Profile';
    is_deeply $object->profile(), \%profile, 'hash instantiation; profile structure ok';
}

###############################################################################
# Instantiation; hash-ref
instantiation_via_hashref: {
    my %profile = (
        required    => [qw(this that)],
        optional    => [qw(other thing)],
        field_filters => {
            this    => ['trim', 'digit'],
            },
        );
    my $object = Data::FormValidator::Profile->new( \%profile );
    isa_ok $object, 'Data::FormValidator::Profile';
    is_deeply $object->profile(), \%profile, 'hashref instantiation; profile structure ok';
}

###############################################################################
# Reduce to only a given set of fields
reduce_only: {
    my %profile = (
        required    => [qw(this that)],
        optional    => [qw(other thing)],
        field_filters => {
            this    => ['trim', 'digit'],
            },
        );
    my $object = Data::FormValidator::Profile->new( %profile );
    isa_ok $object, 'Data::FormValidator::Profile';

    $object->only( qw(this thing) );
    my %expect = (
        required    => [qw(this)],
        optional    => [qw(thing)],
        field_filters => {
            this    => ['trim', 'digit'],
            },
        );
    is_deeply $object->profile(), \%expect, 'reduced to only certain fields';
}

###############################################################################
# Remove a given set of fields
reduce_remove: {
    my %profile = (
        required    => [qw(this that)],
        optional    => [qw(other thing)],
        field_filters => {
            this    => ['trim', 'digit'],
            },
        );
    my $object = Data::FormValidator::Profile->new( %profile );
    isa_ok $object, 'Data::FormValidator::Profile';

    $object->remove( qw(this) );
    my %expect = (
        required    => [qw(that)],
        optional    => [qw(other thing)],
        field_filters => { },
        );
    is_deeply $object->profile(), \%expect, 'removed "this" field';
}

###############################################################################
# Verify interaction with Data::FormValidator; make sure that it'll accept a
# DFV::Profile without choking.
verify_dfv_interaction: {
    my %profile = (
        required    => [qw(this that)],
        optional    => [qw(other thing)],
        );
    my $object = Data::FormValidator::Profile->new( %profile );
    isa_ok $object, 'Data::FormValidator::Profile';

    my $data = {
        'this'  => 'here',
        'that'  => 'there',
        'other' => 'nowhere',
        };
    my $results = Data::FormValidator->check( $data, $object->profile() );
    isa_ok $results, 'Data::FormValidator::Results';
    ok $results->success(), '... validated successfully';
    is $results->valid('this'), 'here',     '... field: this';
    is $results->valid('that'), 'there',    '... field: that';
    is $results->valid('other'), 'nowhere', '... field: other';
}
