package App::cryp::Exchange::bitcoin_indonesia;

# DATE
# VERSION

use 5.010001;
use strict;
use warnings;

use Role::Tiny::With;
with 'App::cryp::Role::Exchange';

sub data_pair_separator { '_' }

sub data_canonical_currencies {
    state $data = {
        require App::btcindo;
        my %hash = %App::btcindo::Canonical_Currencies;
        for my $k (keys %hash) {
            $hash{uc $k} = uc(delete $hash{$k});
        }
        \%hash;
    };
    $data;
}

sub data_reverse_canonical_currencies {
    state $data = {
        require App::btcindo;
        my %hash = %App::btcindo::Rev_Canonical_Currencies;
        for my $k (keys %hash) {
            $hash{uc $k} = uc(delete $hash{$k});
        }
        \%hash;
    };
    $data;
}

sub list_pairs {
    require App::btcindo;
    # XXX in the future, we will put the master data here instead of in
    # App::btcindo

    [200, "OK", $payload];
}

sub new {
    require Finance::BTCIndo;

    my ($class, %args) = @_;

    $args{_client} = Finance::BTCIndo->new(
        key => $args{api_key},
        secret => $args{api_secret},
    );

    bless \%args, $class;
}

sub list_pairs {
}

1;
# ABSTRACT: Interact with Bitcoin Indonesia
