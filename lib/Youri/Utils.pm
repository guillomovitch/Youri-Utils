# $Id$
package Youri::Utils;

=head1 NAME

Youri::Utils - Youri shared functions

=head1 DESCRIPTION

This module implement some helper functions for all youri applications.

=cut

use base qw(Exporter);
use Carp;
use strict;
use warnings;

our @EXPORT = qw(
    send_mail
    create_instance
    load
    add2hash
    add2hash_
);

=head2 send_mail(I<$mail>, I<$path>, I<$test>)

Send a mail.
I<$mail> is a Mime::Entity object representing the mail itself.
I<$path> is the path to the MTA.
I<$test> is a test flag.

=cut

sub send_mail {
    my ($mail, $path, $test) = @_;

    if ($test) {
        $mail->print(\*STDOUT);
    } else {
        open(MAIL, "| $path -t -oi -oem") or die "Can't open MTA program: $!";
        $mail->print(\*MAIL);
        close MAIL;
    }
}

=head2 create_instance(class => I<$class>, I<%options>)

Create an instance of a class at runtime.
I<$class> is the class name.
I<%options> are passed to the class constructor.
Returns the class instance.

=cut

sub create_instance {
    my ($expected_class, %options) = @_;

    die 'No expected class given' unless $expected_class;
    die "No class given, expected derivated class from '$expected_class'" unless $options{class};

    # extract class from options
    my $class = $options{class};
    delete $options{class};

    # ensure loaded
    load($class);

    # check interface
    die "$class is not a $expected_class" unless $class->isa($expected_class);

    # instantiate
    no strict 'refs';
    return $class->new(%options);
}

sub load {
    my ($class) = @_;

    $class .= '.pm';
    $class =~ s/::/\//g;
    require $class;
}

# structure helpers

sub add2hash  { my ($a, $b) = @_; while (my ($k, $v) = each %{$b || {}}) { $a->{$k} ||= $v } $a }
sub add2hash_ { my ($a, $b) = @_; while (my ($k, $v) = each %{$b || {}}) { exists $a->{$k} or $a->{$k} = $v } $a }

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2002-2006, YOURI project

This program is free software; you can redistribute it and/or modify it under the same terms as Perl itself.

=cut

1;
