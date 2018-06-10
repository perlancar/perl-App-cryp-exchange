package App::cryp::Exchange::indodax;

# DATE
# VERSION

use 5.010001;
use strict;
use warnings;

use Role::Tiny::With;
with 'App::cryp::Role::Exchange';

sub new {
    require Finance::Indodax;

    my ($class, %args) = @_;

    unless ($args{public_only}) {
        die "Please supply api_key and api_secret"
            unless $args{api_key} && $args{api_secret};
    }

    $args{_client} = Finance::Indodax->new(
        key => $args{api_key},
        secret => $args{api_secret},
    );

    bless \%args, $class;
}

sub data_native_pair_separator { '_' }

sub data_native_pair_is_uppercase { 0 }

sub data_canonical_currencies {
    state $data = {
        STR => 'XLM',
        DRK => 'DASH',
        NEM => 'XEM',
    };
    $data;
}

sub data_reverse_canonical_currencies {
    state $data = {
        XLM  => 'STR',
        DASH => 'DRK',
        XEM  => 'NEM',
    };
    $data;
}

sub data_pairs {
    state $data = [
        {
            name => 'BTC/IDR',
            min_base_size => undef,
            min_quote_size => 50_000,
            quote_increment => 1000,
        },
        {
            name => 'ACT/IDR',
            min_base_size => undef,
            min_quote_size => 50_000,
            quote_increment => 1,
        },
        {
            name => 'ADA/IDR',
            min_base_size => undef,
            min_quote_size => 50_000,
            quote_increment => 1,
        },
        {
            name => 'BCD/IDR',
            min_base_size => undef,
            min_quote_size => 50_000,
            quote_increment => 100,
        },
        {
            name => 'BCH/IDR',
            min_base_size => undef,
            min_quote_size => 50_000,
            quote_increment => 1000,
        },
        {
            name => 'BTG/IDR',
            min_base_size => undef,
            min_quote_size => 50_000,
            quote_increment => 1000,
        },
        {
            name => 'ETH/IDR',
            min_base_size => undef,
            min_quote_size => 50_000,
            quote_increment => 1000,
        },
        {
            name => 'ETC/IDR',
            min_base_size => undef,
            min_quote_size => 50_000,
            quote_increment => 1000,
        },
        {
            name => 'IGNIS/IDR',
            min_base_size => undef,
            min_quote_size => 50_000,
            quote_increment => 1,
        },
        {
            name => 'LTC/IDR',
            min_base_size => undef,
            min_quote_size => 50_000,
            quote_increment => 1000,
        },
        {
            name => 'NXT/IDR',
            min_base_size => undef,
            min_quote_size => 50_000,
            quote_increment => 1,
        },
        {
            name => 'STQ/IDR',
            min_base_size => undef,
            min_quote_size => 50_000,
            quote_increment => 1,
        },
        {
            name => 'TEN/IDR',
            min_base_size => undef,
            min_quote_size => 50_000,
            quote_increment => 1,
        },
        {
            name => 'TRX/IDR',
            min_base_size => undef,
            min_quote_size => 50_000,
            quote_increment => 1,
        },
        {
            name => 'WAVES/IDR',
            min_base_size => undef,
            min_quote_size => 50_000,
            quote_increment => 100,
        },
        {
            name => 'XLM/IDR',
            min_base_size => undef,
            min_quote_size => 50_000,
            quote_increment => 1,
        },
        {
            name => 'XRP/IDR',
            min_base_size => undef,
            min_quote_size => 50_000,
            quote_increment => 1,
        },
        {
            name => 'XZC/IDR',
            min_base_size => undef,
            min_quote_size => 50_000,
            quote_increment => 1000,
        },

        {
            name => 'BTS/BTC',
            min_base_size => undef,
            min_quote_size => 0.001, # BTC
            quote_increment => "0.00000001", # 1sat
        },
        {
            name => 'DASH/BTC',
            min_base_size => undef,
            min_quote_size => 0.001, # BTC
            quote_increment => "0.000001", # 100sat
        },
        {
            name => 'DOGE/BTC',
            min_base_size => undef,
            min_quote_size => 0.001, # BTC
            quote_increment => "0.00000001", # 1sat
        },
        {
            name => 'ETH/BTC',
            min_base_size => undef,
            min_quote_size => 0.001, # BTC
            quote_increment => "0.000001", # 100sat
        },
        {
            name => 'LTC/BTC',
            min_base_size => undef,
            min_quote_size => 0.001, # BTC
            quote_increment => "0.000001", # 100sat
        },
        {
            name => 'NXT/BTC',
            min_base_size => undef,
            min_quote_size => 0.001, # BTC
            quote_increment => "0.00000001", # 1sat
        },
        {
            name => 'TEN/BTC',
            min_base_size => undef,
            min_quote_size => 0.001, # BTC
            quote_increment => "0.00000001", # 1sat
        },
        {
            name => 'XEM/BTC',
            min_base_size => undef,
            min_quote_size => 0.001, # BTC
            quote_increment => "0.00000001", # 1sat
        },
        {
            name => 'XLM/BTC',
            min_base_size => undef,
            min_quote_size => 0.001, # BTC
            quote_increment => "0.00000001", # 1sat
        },
        {
            name => 'XRP/BTC',
            min_base_size => undef,
            min_quote_size => 0.001, # BTC
            quote_increment => "0.00000001", # 1sat
        },

    ];
    $data;
}

sub list_pairs {
    my ($self, %args) = @_;

    my @res;
    for my $rec0 (@{ $self->data_pairs }) {
        my $rec = {%$rec0};
        $rec->{name} =~ m!(.+)/(.+)!;
        $rec->{base_currency} = $1;
        $rec->{quote_currency} = $2;
        if ($args{native}) {
            $rec->{name} = $self->to_native_pair($rec->{name});
            $rec->{base_currency} = $self->to_native_currency($rec->{base_currency});
            $rec->{quote_currency} = $self->to_native_currency($rec->{quote_currency});
        }
        push @res, $rec;
    }

    unless ($args{detail}) {
        @res = map { $_->{name} } @res;
    }

    [200, "OK", \@res];
}

sub get_order_book {
    my ($self, %args) = @_;

    my $pair = lc $self->to_native_pair($args{pair});

    my $apires;
    eval { $apires = $self->{_client}->get_depth(pair => $pair) };
    return [500, "Died: $@"] if $@;

    [200, "OK", $apires];
}

sub list_balances {
    my ($self, %args) = @_;

    my $apires;
    eval { $apires = $self->{_client}->get_info };
    return [500, "Died: $@"] if $@;

    my @recs;
    for my $currency0 (sort keys %{$apires->{return}{balance}}) {
        my $avail = $apires->{return}{balance}{$currency0} // 0;
        my $hold  = $apires->{return}{balance_hold}{$currency0} // 0;
        my $rec = {
            currency  => $self->to_canonical_currency($currency0),
            available => $avail,
            hold      => $hold,
            total     => $avail + $hold,
        };
        push @recs, $rec;
    }

    [200, "OK", \@recs];
}

1;
# ABSTRACT: Interact with Indodax

=for Pod::Coverage ^(.+)$

=head1 DRIVER-SPECIFIC NOTES

C<list_pairs()> is manually maintained by this driver instead of using an API,
because Indodax does not provide an API to list markets/pairs (let alone a
public one). The closest is C<getInfo()> but that only gives balances of all
available coins and not pairs.
