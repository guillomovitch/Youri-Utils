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
use DateTime;
use English qw(-no_match_vars);
use UNIVERSAL::require;
use version; our $VERSION = qv('0.3.0');
use Youri::Error::WrongClass;
use Youri::Error::ClassNotFound;

our @EXPORT = qw(
    create_instance
    log_message
);

=head2 create_instance($class, $config, $options)

Create an instance from a plugin implementing given interface, using given
configuration and local options.
Returns a plugin instance, or undef if something went wrong.

=cut

sub create_instance {
    my ($interface, $config, $options) = @_;

    throw Youri::Error::Coding(
        "No interface given"
    ) unless $interface;

    throw Youri::Error::Coding(
        "No configuration given"
    ) unless $config;

    my $class = $config->{class};
    throw Youri::Error::Coding(
        "No class given"
    ) unless $class;

    # ensure loaded
    throw Youri::Error::ClassNotFound("class $class not found")
        unless $class->require();

    # check interface
    throw Youri::Error::WrongClass("class $class doesn't implement $interface") 
        unless $class->isa($interface);

    return $class->new(
        $config->{options} ? %{$config->{options}} : (),
        $options ? %{$options} : (),
    );
}

=head2 log_message($message, $time, $process)

=cut

sub log_message {
    my ($message, $time, $process) = @_;

    print DateTime->now()->set_time_zone('local')->strftime('[%H:%M:%S] ')
        if $time;
    print "$PID " if $process;
    print "$message\n";
}

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2002-2006, YOURI project

This program is free software; you can redistribute it and/or modify it under the same terms as Perl itself.

=cut

1;
