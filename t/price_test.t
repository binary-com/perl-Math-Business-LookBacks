#!/etc/rmg/bin/perl

use strict;
use warnings;

use Test::Most;
use Test::Warn;
use Test::Exception;
use Math::Business::LookBacks;
use Format::Util::Numbers qw(roundnear);

subtest 'test_price' => sub {

    test_price({    # Fixed strike lookback call
            type          => 'lbfixedcall',
            strike        => 101,
            spot          => 100,
            discount_rate => 0.4,
            t             => 0.1,
            mu            => 0.3,
            vol           => 0.1,
            spot_max      => 102,
            spot_min      => undef
        },
        3.5007
    );

    test_price({    # Fixed strike lookback put
            type          => 'lbfixedput',
            strike        => 105,
            spot          => 100,
            discount_rate => 0.4,
            t             => 0.1,
            mu            => 0.3,
            vol           => 0.1,
            spot_max      => undef,
            spot_min      => 95
        },
        9.62282
    );

    test_price({    # Floating strike lookback call
            type          => 'lbfloatcall',
            strike        => 100,
            spot          => 100,
            discount_rate => 0.4,
            t             => 0.1,
            mu            => 0.3,
            vol           => 0.1,
            spot_max      => undef,
            spot_min      => 95
        },
        7.74492
    );

    test_price({    # Floating strike lookback put
            type          => 'lbfloatput',
            strike        => 100,
            spot          => 100,
            discount_rate => 0.4,
            t             => 0.1,
            mu            => 0.3,
            vol           => 0.1,
            spot_max      => 105,
            spot_min      => undef
        },
        2.68164
    );

    test_price({    # High low lookback
            type          => 'lbhighlow',
            strike        => 100,
            spot          => 100,
            discount_rate => 0.4,
            t             => 0.1,
            mu            => 0.3,
            vol           => 0.1,
            spot_max      => 105,
            spot_min      => 95
        },
        10.42656
    );

};

#$S, $K, $t, $r_q, $mu, $sigma, $S_min or $S_min or both.

sub test_price {
    my $args     = shift;
    my $expected = shift;

    my $type          = $args->{type};
    my $strike        = $args->{strike};
    my $spot          = $args->{spot};
    my $discount_rate = $args->{discount_rate};
    my $t             = $args->{t};
    my $mu            = $args->{mu};
    my $sigma         = $args->{vol};
    my $s_max         = $args->{spot_max};
    my $s_min         = $args->{spot_min};

    my $price;

    my $formula = 'Math::Business::LookBacks::' . $type;

    my $func = \&$formula;

    if (defined $s_max and defined $s_min) {
        $price = $func->($spot, $strike, $t, $discount_rate, $mu, $sigma, $s_max, $s_min);
    } elsif (defined $s_max and not defined $s_min) {
        $price = $func->($spot, $strike, $t, $discount_rate, $mu, $sigma, $s_max);
    } else {
        $price = $func->($spot, $strike, $t, $discount_rate, $mu, $sigma, $s_min);
    }

    is roundnear(0.00001, $price), roundnear(0.00001, $expected), "correct price for " . $type;
}

done_testing;

