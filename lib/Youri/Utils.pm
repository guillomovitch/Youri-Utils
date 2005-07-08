# $Id$
package Youri::Utils;

=head1 NAME

Youri::Utils - Youri shared functions

=head1 DESCRIPTION

This module implement some helper functions for all youri applications.

=cut

use base qw(Exporter);
use Carp;
use URPM;
use strict;
use warnings;

our @EXPORT = qw(
    get_canonical_name
    send_mail
    create_instance
    add2hash
    add2hash_
);

=head2 get_rpm(I<$file>)

Returns an URPM::Package object corresponding to file I<$file>.

=cut

# sub get_rpm {
#     my ($file) = @_;
# 
#     my $urpm = URPM->new();
#     $urpm->parse_rpm($file, keep_all_tags => 1);
#     return $urpm->{depslist}->[0];
# }

=head2 get_canonical_name(I<$package>)

Returns canonical name (aka name of the source package) for URPM::Package
object I<$package>. 

=cut

sub get_canonical_name {
    my ($package) = @_;

    my $arch = $package->arch();
    my $name;

    if ($arch eq 'src') {
       $name = $package->name();
    } else {
       $package->sourcerpm() =~ /^(\S+)-[^-]+-[^-]+\.src\.rpm$/;
       $name = $1;
    }

    return $name;
}

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
    my $file = $class;
    $file .= '.pm';
    $file =~ s/::/\//g;
    require $file;

    # check interface
    die "$class is not a $expected_class" unless $class->isa($expected_class);

    # instantiate
    no strict 'refs';
    return $class->new(%options);
}

# structure helpers

sub add2hash  { my ($a, $b) = @_; while (my ($k, $v) = each %{$b || {}}) { $a->{$k} ||= $v } $a }
sub add2hash_ { my ($a, $b) = @_; while (my ($k, $v) = each %{$b || {}}) { exists $a->{$k} or $a->{$k} = $v } $a }


1;
