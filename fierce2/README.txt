================================================================================
                            - README - 
================================================================================

* Installation
* What is new in 2.0 ?
* Description

*******************
Installation
*******************

## standard install

perl Makefile.PL
make
make test ## -> if this fails, run: sudo installdep.sh 
sudo make install

## Install templates

mkdir ~/.fierce2/
cp -r tt ~/fierce2/


*******************
What is new in 2.0?
*******************
Fierce v2.0 is a complete rewrite of version 1.0. Fierce 1.0 was a combination
multiple network enumeration techniques in a single large Perl script. With
Fierce v2.0 the techniques have been abstracted from the main fierce script so
that it is easier to read, modify and maintain. This will enable faster 
development and greater flexibility.

Each technique has been coverted into a Perl module that they can be used used
by the main fierce script. There are also several new techniques that been
added with version 2.0, such as virtual host detection, extension bruteforcing
and subdomain bruteforcing. Version 2.0 also included the addition of
a template based output system. We have included stdout/text, html  and xml
formats. Leveraging the xml format is very easy, since we have even built an
xml parsing module that is available on CPAN.

http://search.cpan.org/~jabra/

(click on Fierce::Parser, this will bring you to the latest version of the
 Fierce::Parser module.)

***********
Description 
***********

Fierce domain scan was born out of a frustration after performing web
application security audits. It is traditionally very difficult to discover
large swaths of a corporate network that are non-contiguous. It's terribly easy
to run a scanner against an IP range, but if the IP ranges are nowhere near one
another you can miss huge chunks of networks.

Fierce is a reconnaissance tool, that was designed to locate likely targets
both inside and outside a corporate network using passive techniques. Fierce 
is a Perl script and several modules that quickly scans domains (usually in 
just a few minutes, assuming no network lag) using several tactics.

The details of the techniques are included in the docs/METHODS.txt file.
