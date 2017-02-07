use threads;
use threads::shared;
use strict;
use warnings;

use ExtUtils::MakeMaker;
WriteMakefile(
    NAME                => 'Fierce::Base',
    AUTHOR              => 'Joshua "Jabra" Abraham < jabra@spl0it.org >',
    VERSION             => '2.0',
    'EXE_FILES'         =>  [ 'fierce' ],
    'MAN1PODS'    => {
        'fierce.man.1'   => 'blib/man1/fierce.1p',
    },
    PREREQ_PM           => {
                'Test::More'        => '0',
                'Object::InsideOut' => '0',
                'Test::Class'       => '0',
                'Net::DNS'          => '0',
                'Net::CIDR'         => '0',
                'Net::Whois::ARIN'  => '0',
                'Template'          => '0',
                'threads'           => '0',
                'threads::shared'   => '0',
                'Thread::Queue'     => '0',
                'Test::MockObject' => '0',
                'WWW::Mechanize' => '0',
    },
    'INSTALLDIRS' => 'site',    
    'dist' => {
        'SUFFIX'       => ".gz",
        'DIST_DEFAULT' => 'all tardist',
        'COMPRESS'     => "gzip -9f"
    },
    'realclean' => { 'FILES' => '' },
    'clean'     => { 'FILES' => '' },
);
