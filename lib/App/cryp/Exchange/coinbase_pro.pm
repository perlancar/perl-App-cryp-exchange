package App::cryp::Exchange::coinbase_pro;

# DATE
# VERSION

use 5.010001;
use strict;
use warnings;

use Role::Tiny::With;
with 'App::cryp::Role::Exchange';

sub new {
    require Finance::CoinbasePro::Lite;

    my ($class, %args) = @_;

    unless ($args{public_only}) {
        die "Please supply api_key, api_secret, api_passphrase"
            unless $args{api_key} && $args{api_secret}
            && defined $args{api_passphrase};
    }

    $args{_client} = Finance::CoinbasePro::Lite->new(
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

    my $apires = $self->{_client}->public_request(GET => "/products");
    return $apires unless $apires->[0] == 200;

    my @res;
    for (@{ $apires->[2] }) {
        my $pair;
        if ($args{native}) {
            $pair = $self->to_native_pair($_->{id});
        } else {
            $pair = $self->to_canonical_pair($_->{id});
        }
        push @res, {
            pair            => $pair,
            quote_increment => $_->{quote_increment},
            status          => $_->{status}, # online,
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

    my $apires = $self->{_client}->public_request(GET => "/products/$pair/book?level=2");
    return $apires unless $apires->[0] == 200;

    $apires->[2]{buy}  = delete $apires->[2]{bids};
    $apires->[2]{sell} = delete $apires->[2]{asks};

    # remove the num-orders part
    for (@{ $apires->[2]{buy} }, @{ $apires->[2]{sell} }) {
        splice @$_, 2;
    }

    [200, "OK", $apires->[2]];
}

sub list_balances {
    my ($self, %args) = @_;

    my $apires = $self->{_client}->private_request(GET => "/accounts");
    return $apires unless $apires->[0] == 200;

    my @res;
    for (@{ $apires->[2] }) {
        my $rec = {
            currency  => $self->to_canonical_currency($_->{currency}),
            available => $_->{available},
            hold      => $_->{hold},
            total     => $_->{balance},
        };
        push @res, $rec;
    }

    [200, "OK", \@res];
}

1;
# ABSTRACT: Interact with Coinbase Pro

=for Pod::Coverage ^(.+)$
