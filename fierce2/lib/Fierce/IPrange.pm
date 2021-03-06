# $Id: IPrange.pm 371 2010-06-11 03:17:20Z jabra $
package IPrange;
{
    use Object::InsideOut;
    use Net::CIDR ':all';
    my @iprange : Field : Arg(iprange) : Get(iprange) : Type(Array);

    # top of the classc range
    sub top_classc {
        my ( $self, $first_three_octets ) = @_;
        my @cidrs;
        my $top;
        if ( defined( $self->iprange ) and ref( $self->iprange ) eq 'ARRAY' )
        {
            foreach my $i ( @{ $self->iprange } ) {
                chomp($i);
                if ( $i =~ /^(\d{1,3}\.\d{1,3}\.\d{1,3})\.(\d{1,3})$/ ) {
                    my ( $three_octets, $fourth ) = ( $1, $2 );
                    if ( $three_octets eq $first_three_octets ) {
                        if ( !defined($top) or $top < $fourth ) {
                            $top = $fourth;
                        }
                    }
                }
            }
        }
        return $top;
    }

    # bottom of the classc range
    sub bottom_classc {
        my ( $self, $first_three_octets ) = @_;
        my @cidrs;
        my $bottom;
        if ( defined( $self->iprange ) and ref( $self->iprange ) eq 'ARRAY' )
        {
            foreach my $i ( @{ $self->iprange } ) {
                chomp($i);
                if ( $i =~ /^(\d{1,3}\.\d{1,3}\.\d{1,3})\.(\d{1,3})$/ ) {
                    my ( $three_octets, $fourth ) = ( $1, $2 );
                    if ( $three_octets eq $first_three_octets ) {
                        $bottom = $fourth if ( !defined($bottom) );
                        if ( $bottom > $fourth ) {
                            $bottom = $fourth;
                        }
                    }
                }
            }
        }
        return $bottom;
    }

    # find all the class's that are included.
    sub group {
        my ( $self, $cidr, $low, $high ) = @_;
        my @group;
        for my $oct ( $low .. $high ) {
            push( @group, "$cidr.$oct" );
        }
        return @group;
    }

    # find all the class's that are included.
    sub included_cidrs {
        my ($self) = @_;
        my @cidrs;
        if ( defined( $self->iprange ) and ref( $self->iprange ) eq 'ARRAY' )
        {
            foreach my $i ( @{ $self->iprange } ) {
                if ( $i =~ /(\d{1,3}\.\d{1,3}\.\d{1,3})/ ) {
                    my $ip = $1;
                    if ( scalar( grep( $_ eq $ip, @cidrs ) ) == 0 ) {
                        push( @cidrs, $ip );
                    }
                }
            }
        }
        return @cidrs;
    }

    sub convert_octets {
        my ($self)    = @_;
        my @cidr_list = $self->convert_cidrs();
        my @tmp       = Net::CIDR::cidr2octets(@cidr_list);
        my @octets;
        foreach (@tmp) {
            chomp;
            if (/^(\d{1,3}\.\d{1,3}\.\d{1,3})$/) {
                foreach my $i ( 1 .. 254 ) {
                    chomp($i);
                    push( @octets, "$1.$i" );
                }
            }
            elsif (/^\d{1,3}\.\d{1,3}\.\d{1,3}.\d{1,3}$/) {
                push( @octets, $_ );
            }
            else { }
        }
        return @octets;
    }

    # return the ranges format of all the values in the obj
    sub convert_ranges {
        my ($self) = @_;
        my @ranges;
        if ( defined( $self->iprange ) and ref( $self->iprange ) eq 'ARRAY' )
        {
            foreach ( @{ $self->iprange } ) {
                chomp;
                s/\s+//g;
                if (/^(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,2}\/\d{1,2})$/) {
                    push( @ranges,
                        join( "\n", Net::CIDR::cidr2range("$1") ) );
                }
                elsif (/^(\d{1,3}\.\d{1,3}\.\d{1,3})\.(\d{1,3})\-(\d{1,3})$/)
                {
                    push( @ranges, "$1.$2-$1.$3" );
                }
                elsif (/^(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})$/) {
                    push( @ranges, $1 );
                }
                else { }
            }
        }
        return @ranges;
    }

    # return the cidr of all values in the obj
    sub convert_cidrs {
        my ($self) = @_;
        my @cidrs;

        if ( defined( $self->iprange ) and ref( $self->iprange ) eq 'ARRAY' )
        {
            foreach ( @{ $self->iprange } ) {
                chomp;
                s/\s+//g;
                if (/^(\d{1,3})\.(\d{1,3})\.(\d{1,3})\.(\d{1,3})\-(\d{1,3})$/)
                {
                    push( @cidrs,
                        Net::CIDR::range2cidr("$1.$2.$3.$4-$1.$2.$3.$5") );
                }
                elsif (
                    /^(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\-\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})$/
                    )
                {
                    push( @cidrs, Net::CIDR::range2cidr($1) );
                }
                elsif (/^(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,2}\/\d{1,2})$/) {
                    push( @cidrs, $1 );
                }
                elsif (
                    /^(\d{1,3})\.(\d{1,3})\.(\d{1,3})\.(\d{1,3})\-\d{1,3}$/)
                {
                    push( @cidrs,
                        Net::CIDR::range2cidr("$1.$2.$3.$4-$1.$2.$3.$5") );
                }
                elsif (/^(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})$/) {
                    push( @cidrs, $1 );
                }
                else { }
            }
        }
        return @cidrs;
    }
}
1;
