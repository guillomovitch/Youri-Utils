# $Id$
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME       => 'youri',
    VERSION    => 0.9,
    AUTHOR     => 'Youri project <youri@zarb.org>',
    EXE_FILES  => [ 'bin/youri-check', 'bin/youri-upload' ],
    PREREQ_PM  => {
        'AppConfig' => 0,
        'YAML'      => 0,
        'DateTime'  => 0,
    }
);

package MY;

sub post_constants {
    my ($self) = @_;
    my $sysconfdir =
        $self->{ARGS}->{SYSCONFDIR} ||
        ($self->{INSTALLDIRS} eq 'site' ?
            '/usr/local/etc' :
            '/usr/etc');
    return <<EOF;
SYSCONFDIR = $sysconfdir
EOF
}

sub install {
    my ($self) = @_;
    my $install = $self->SUPER::install(@_);
    $install =~ s/install :: all pure_install doc_install/install :: all pure_install doc_install config_install completion_install/;
    $install .= <<'EOF';
config_install :
	install -d -m 755 $(DESTDIR)$(SYSCONFDIR)/youri
	install -m 644 etc/check.conf $(DESTDIR)$(SYSCONFDIR)/youri
	install -m 644 etc/upload.conf $(DESTDIR)$(SYSCONFDIR)/youri

completion_install :
	install -d -m 755 $(DESTDIR)$(SYSCONFDIR)/bash_completion.d
	install -m 644 etc/bash_completion.d/youri $(DESTDIR)$(SYSCONFDIR)/bash_completion.d
EOF
    return $install;
}

sub installbin {
    my ($self) = @_;
    my $installbin = $self->SUPER::installbin(@_);
    $installbin .= <<'EOF';
bin/youri-check : bin/youri-check.in Makefile
	perl -p \
	    -e 's|\@sysconfdir\@|$(SYSCONFDIR)|;' \
	    < $< > $@

bin/youri-upload : bin/youri-upload.in Makefile
	perl -p \
	    -e 's|\@sysconfdir\@|$(SYSCONFDIR)|;' \
	    < $< > $@
EOF
    return $installbin;
}
