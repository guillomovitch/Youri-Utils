# $Id$
package Youri::Utils;

=head1 NAME

Youri::Utils - Youri shared functions

=head1 DESCRIPTION

This module implement some helper functions for all youri applications.

=cut

use strict;
use warnings;
use base qw(Exporter);
use Carp;
use UNIVERSAL::require;
use version; our $VERSION = qv('0.1.0');

our @EXPORT = qw(
    create_instance
    load_class
    add2hash
    add2hash_
);

=head2 create_instance($class, $config, $options)

Create an instance from a plugin implementing given interface, using given
configuration and local options.
Returns a plugin instance, or undef if something went wrong.

=cut

sub create_instance {
    my ($interface, $config, $options) = @_;

    croak 'No interface given' unless $interface;
    croak 'No config given' unless $config;

    my $class = $config->{class};
    if (!$class) {
        carp "No class given, can't load plugin";
        return;
    }

    # ensure loaded
    $class->require();

    # check interface
    if (!$class->isa($interface)) {
        carp "$class is not a $interface";
        return;
    }

    return $class->new(
        $config->{options} ? %{$config->{options}} : (),
        $options ? %{$options} : (),
    );
}

sub load_class {
    my ($class) = @_;
    carp "Deprecated method, use UNIVERSAL::require now";

    $class->require();
}

# structure helpers

sub add2hash  {
    my ($a, $b) = @_;
    carp "Deprecated method, to be dropped in next release";
    while (my ($k, $v) = each %{$b || {}}) {
        $a->{$k} ||= $v;
    }
    return $a;
}

sub add2hash_ {
    my ($a, $b) = @_;
    carp "Deprecated method, to be dropped in next release";
    while (my ($k, $v) = each %{$b || {}}) {
        exists $a->{$k} or $a->{$k} = $v;
    }
    return $a;
}

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2002-2006, YOURI project

This program is free software; you can redistribute it and/or modify it under the same terms as Perl itself.

=cut

1;
