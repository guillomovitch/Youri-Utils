# $Id$
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME       => 'youri',
    VERSION    => 0.1,
    AUTHOR     => 'Guillaume Rousse <guillomovitch@zarb.org>',
    EXE_FILES  => [ 'bin/rpmcheck', 'bin/genhdlist' ],
    PREREQ_PM  => {
        'AppConfig'       => 0,
        'CGI'             => 0,
        'DBI'             => 0,
        'Expect'          => 0,
        'File::Temp'      => 0,
        'File::Find'      => 0,
        'List::MoreUtils' => 0,
        'LWP::Simple'     => 0,
        'MIME::Entity'    => 0,
        'SOAP::Lite'      => 0,
        'URPM'            => 0,
        'XML::RSS'        => 0,
        'XML::Twig'       => 0,
        'YAML'            => 0,
    }
);
