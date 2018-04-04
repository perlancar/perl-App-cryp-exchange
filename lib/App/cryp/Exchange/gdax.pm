package App::cryp::Exchange::gdax;

# DATE
# VERSION

use 5.010001;
use strict;
use warnings;

use Role::Tiny::With;
with 'App::cryp::Role::Exchange';

sub new {
    require Finance::GDAX::Lite;

    my ($class, %args) = @_;

    unless ($args{public_only}) {
        die "Please supply api_key, api_secret, api_passphrase"
            unless $args{api_key} && $args{api_secret}
            && defined $args{api_passphrase};
    }

    $args{_client} = Finance::GDAX::Lite->new(
        key => $args{api_key},
        secret => $args{api_secret},
        passphrase => $args{api_passphrase},
    );

    bless \%args, $class;
}

sub data_native_pair_separator { '-' }

sub data_canonical_currencies {
    state $data = {};
    $data;
}

sub data_reverse_canonical_currencies {
    state $data = {};
    $data;
}

sub list_pairs {
    my ($self, %args) = @_;

    my $res = $self->{_client}->public_request(GET => "/products");
    return $res unless $res->[0] == 200;

    my @res;
    for (@{ $res->[2] }) {
        my $pair;
        if ($args{native}) {
            $pair = $self->to_native_pair($_->{id});
        } else {
            $pair = $self->to_canonical_pair($_->{id});
        }
        push @res, {
            pair            => $pair,
            quote_increment => $_->{quote_increment},
            status          => $_->{status},
        };
    }

    unless ($args{detail}) {
        @res = map { $_->{pair} } @res;
    }

    [200, "OK", \@res];
}

sub get_order_book {
    my ($self, %args) = @_;

    my $pair = $self->to_native_pair($args{pair});

    my $res = $self->{_client}->public_request(GET => "/products/$pair/book?level=2");
    return $res unless $res->[0] == 200;

    my @res;
    {
        last if $args{type} && $args{type} ne 'buy';
        for my $rec (@{ $res->[2]{bids} }) {
            push @res, {
                type   => "buy",
                price  => $rec->[0],
                amount => $rec->[1],
            };
        }
    }
    {
        last if $args{type} && $args{type} ne 'sell';
        for my $rec (@{ $res->[2]{asks} }) {
            push @res, {
                type   => "sell",
                price  => $rec->[0],
                amount => $rec->[1],
            };
        }
    }

    [200, "OK", \@res];
}

1;
# ABSTRACT: Interact with Bitcoin Indonesia

=for Pod::Coverage ^(.+)$
