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
    get_rpm
    analysis
);

=head2 send_mail(I<$config>, I<$mail>)

Send a mail.
I<$config> is an AppConfig object used to determine test status and MTA path.
I<$mail> is a Mime::Entity object representing the mail itself.

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

=head2 create_instance(I<$prefix>, I<$string>)

Create an instance of a class at runtime.
I<$prefix> is appended to class name.
I<$string> is a stringified representation of the class constructor's call.
Returns the class instance.

=cut

sub create_instance {
    my (%options) = @_;

    return unless $options{class};

    # extract class from options
    my $class = $options{class};
    delete $options{class};

    # ensure loaded
    my $file = $class;
    $file .= '.pm';
    $file =~ s/::/\//g;
    require $file;

    # instantiate
    no strict 'refs';
    return $class->new(%options);
}

=head2 get_rpm(I<$file>)

Get a rpm object from a file.
I<$file> is the rpm file.
Returns an URPM::Package object.

=cut

sub get_rpm {
    my ($file) = @_;

    my $urpm = URPM->new();
    $urpm->parse_rpm($file, keep_all_tags => 1);
    return $urpm->{depslist}->[0];
}

sub analysis {
    my ($package) = @_;

    my $arch = $package->arch();

    my ($name, $unit);
    if ($arch eq 'src') {
	$name = $package->name();
	$unit = $name;
    } else {
	$package->sourcerpm() =~ /^(\S+)-[^-]+-[^-]+\.src\.rpm$/;
	$name = $1;
	$unit = $package->name();
    }

    return $name, $arch, $unit;
}

1;
