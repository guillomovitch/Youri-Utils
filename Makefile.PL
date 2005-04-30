# $Id$
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME       => 'youri',
    VERSION    => 0.1,
    AUTHOR     => 'Guillaume Rousse <guillomovitch@zarb.org>',
    EXE_FILES  => [ 'bin/rpmcheck', 'bin/rpmupload', 'bin/genhdlist' ],
    PREREQ_PM  => {
        'CGI'          => 0,
        'DBI'          => 0,
        'URPM'         => 0,
        'Expect'       => 0,
        'AppConfig'    => 0,
        'XML::RSS'     => 0,
        'MIME::Entity' => 0,
        'SOAP::Lite'   => 0
    }

);
