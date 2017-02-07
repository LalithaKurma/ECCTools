#!/bin/bash
#######################################################
#
#   Wicked ghetto Fierce2 installer v0.1
#
#######################################################


if [ $EUID -ne 0 ]; then
    echo "This script needs to run as root. Trying sudo..."
    sudo bash $0;

    
    # this step really shouldn't have to exist. Templates in a global directory should be accessible to fierce. 
    #if [ ! -d ~/.fierce2/tt ]; then
    #    mkdir ~/.fierce2/
    #    cp -r tt ~/.fierce2/
    #fi

    exit;

fi

which fierce && {
    echo "Dude, you've already got fierce installed. Or something. Maybe you wanted to upgrade. I dunno."

    exit;

}
which cpanm || {
        # is cpanMinus installed? ( used to handle dependencies )
        # http://search.cpan.org/~miyagawa/App-cpanminus-1.0004/lib/App/cpanminus.pm

    which git || { # turns out git isn't installed on ubuntu by default  :P
        apt-get install git-core
    }

    git clone git://github.com/miyagawa/cpanminus.git
    cd cpanminus
    perl Makefile.PL
    make install

    cd ${OLDPWD}

}

which svn || { # or subversion...  :P
    apt-get install subversion
}

# All that effort just to set up these 5 lines

svn co https://svn.assembla.com/svn/fierce/fierce2/trunk/ fierce2/
cd fierce2
cpanm Exception::Class
cpanm --installdeps .
make install
mkdir ~/.fierce2/
cp -r tt ~/.fierce2/

