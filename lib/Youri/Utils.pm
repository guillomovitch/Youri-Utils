# $Id$
package Youri::Utils;

=head1 NAME

Youri::Utils - Youri shared functions

=head1 DESCRIPTION

This module implement some helper functions.

=head1 Functions

In all of those functions, a package object is an hash with the following keys:

=over

=item file

the file corresponding to this package

=item rpm

an URPM::Package object corresponding to this package

=item dest

The installation directory for this package

=back

=cut

use base qw(Exporter);
use URPM;
use Carp;
use strict;
use warnings;

our @EXPORT = qw(
    send_mail
    create_instance
    get_rpm
    get_older_releases
    get_newer_releases
    get_obsoleted_releases
    get_files
    get_children
);

=head2 send_mail(I<$config>, I<$mail>)

Send a mail.
I<$config> is an AppConfig object used to determine test status and MTA path.
I<$mail> is a Mime::Entity object representing the mail itself.

=cut

sub send_mail {
    my ($config, $mail) = @_;

    if ($config->test()) {
	$mail->print(\*STDOUT);
    } else {
	open(MAIL, "| $config->mail_mta() -t -oi -oem") or die "Can't open MTA program: $!";
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
    my ($prefix, $string) = @_;
    return unless $string;
    my ($module, $options) = $string =~ /(\w+)(?:\((.+)\))?/;
    # format options
    my @options;
    if ($options) {
	$options =~ s/^\s+//;
	$options =~ s/\s+$//;
	@options = split(/,\s*|\s*=>\s*/, $options);
    } else {
	@options = ();
    }
    # ensure loaded
    my $file = $prefix . '::' . $module . '.pm';
    $file =~ s/::/\//g;
    require $file;
    # instantiate
    no strict 'refs';
    my $class = $prefix . '::' . $module;
    return $class->new(@options);
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

=head2 get_older_releases(I<$package>)

Get all older releases from a package found in its installation directory, as a
list of package objects.

=cut

sub get_older_releases {
    my ($package) = @_;

    return get_releases(
	$package,
	sub { return $package->{rpm}->compare_pkg($_[0]->{rpm}) > 0 }
    );
}

=head2 get_newer_releases(I<$package>)

Get all newer releases from a package found in its installation directory, as a
list of package objects.

=cut

sub get_newer_releases {
    my ($package) = @_;

    return get_releases(
	$package,
	sub { return $_[0]->{rpm}->compare_pkg($package->{rpm}) > 0 }
    );
}

=head2 get_obsoleted_releases(I<$package>)

Get all obsoleted releases from a package found in its installation directory, as a
list of package objects.

=cut

sub get_obsoleted_releases {
    my ($package) = @_;

    my @packages;
    foreach my $obsolete ($package->{rpm}->obsoletes()) {
	my $pattern = $obsolete . '-[^-]+-[^-]+\.[\d\w]+\.rpm';
	push(@packages,
	    map { { file => $_, rpm => get_rpm($_)  } } # aggregate file and object
	    get_files($package->{dest}, $pattern)
	);
    }

    return @packages;
}

=head2 get_releases(I<$package>, I<$filter>)

Get all releases from a package found in its installation directory, using an
optional filter, as a list of package objects.

=cut

sub get_releases {
    my ($package, $filter) = @_;

    my $name = $package->{rpm}->name();
    my $pattern;

    # lib policy: package names are versioned
    if ($name =~ /^(lib\w+[a-zA-Z_])[\d_\.]+([-\w]*)$/) {
	$pattern = '^' . $1 . '[\d\._]+' . $2 . '-[^-]+-[^-]+\.\w+\.rpm$';
    } else {
	$pattern = '^' . $name . '-[^-]+-[^-]+\.\w+\.rpm$';
    }

    my @packages = 
       	map { { file => $_, rpm => get_rpm($_) } } # aggregate file and object
	get_files($package->{dest}, $pattern);

    @packages = grep { $filter->($_) } @packages if $filter;

    return
	sort { $b->{rpm}->compare_pkg($a->{rpm}) } # sort by release order
	@packages;
}

=head2 get_files(I<$dir>, I<$pattern>)

Get all files found in a directory, using an optional filtering pattern, as a
list of files.

=cut

sub get_files {
    my ($dir, $pattern) = @_;

    my @files =
	grep { -f }
	glob "$dir/*";

    @files = grep { /$pattern/ } @files if $pattern;

    return @files;
}

=head2 get_children(I<$package>)

Get all binary packages produced by this source package, as a list of names.

=cut 

sub get_children {
    my ($package) = @_;

    croak "not a source package" unless $package->{rpm}->arch() eq 'src';

    my $file = abs_path($package->{file});
    my $name = $package->{rpm}->name();

    # remember original directory
    my $original_dir = cwd();

    # get a safe temporary directory
    my $dir = tempdir( CLEANUP => 1 );
    chdir $dir;

    # extract spec file
    system("rpm2cpio $file | cpio -id $name.spec >/dev/null 2>&1");

    my (%macros, @children);
    open(SPEC, "$name.spec") or die "Can't open spec file: $!";
    while(<SPEC>) {
	if (/^%define\s+(\w+)\s+(\w+)/) {
	    $macros{$1} = $2;
	}
	if (/^%files(?:\s+(-n))?(?:\s+(\w+))?/) {
	    my $child = $2 ?
		$1 ?
		    $2:
		    $name . '-' . $2:
		$name;
	    push(@children, $child);
	}
    }
    close(SPEC);

    # macro extension
    foreach my $child (@children) {
	while ($child =~ s/%{?(\w+)}?/$macros{$1}/) {};
    }

    # get back to original directory
    chdir $original_dir;

    return @children;
}

sub get_dest_dir {
    my ($base, $release, $distrib, $section, $rpm) = @_;

    my $name = $rpm->name();
    my $arch = $rpm->arch();

    my $path = ($arch eq 'src') ?
	$config->source_rpms_dir() :
	$config->binary_rpms_dir() ;

    # perform substitutions
    $path =~ s/%{release}/$release/g;
    $path =~ s/%{distrib}/$distrib/g;
    $path =~ s/%{section}/$section/g;
    $path =~ s/%{name}/$name/g;
    $path =~ s/%{arch}/$arch/g;

    return $base . '/' . $path;
}

1;
