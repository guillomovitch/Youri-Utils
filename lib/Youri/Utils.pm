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

1;
