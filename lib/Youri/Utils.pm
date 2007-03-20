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
use DateTime;
use version; our $VERSION = qv('0.1.1');

our @EXPORT = qw(
    create_instance
    load_class
    log_message
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

=head2 load_class($class)

Ensure given class is loaded.

=cut

sub load_class {
    my ($class) = @_;
    carp "Deprecated method, use UNIVERSAL::require now";

    $class->require();
}

=head2 log_message($message, $time, $process)

=cut

sub log_message {
    my ($message, $time, $process) = @_;

    print DateTime->now()->set_time_zone('local')->strftime('[%H:%M:%S] ')
        if $time;
    print "$$ " if $process;
    print "$message\n";
}

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2002-2006, YOURI project

This program is free software; you can redistribute it and/or modify it under the same terms as Perl itself.

=cut

1;
