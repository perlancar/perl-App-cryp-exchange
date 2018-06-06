package App::cryp::Exchange::cryptopia;

# DATE
# VERSION

use 5.010001;
use strict;
use warnings;
use Log::Log4perl;

use Role::Tiny::With;
with 'App::cryp::Role::Exchange';

sub new {
    require WebService::Cryptopia;

    my $log4perl_conf = <<'_';
log4perl.logger = TRACE, LogGer1
log4perl.appender.LogGer1 = Log::Log4perl::Appender::LogGer
log4perl.appender.LogGer1.layout = Log::Log4perl::Layout::SimpleLayout
_
    Log::Log4perl::init(\$log4perl_conf);

    my ($class, %args) = @_;

    die "Please supply api_key, api_secret"
        unless $args{api_key} && $args{api_secret};

    $args{_client} = WebService::Cryptopia->new(
        api_key    => $args{api_key},
        api_secret => $args{api_secret},
    );

    bless \%args, $class;
}

sub data_native_pair_separator { '/' }

sub data_canonical_currencies {
    # XXX
    state $data = {};
    $data;
}

sub data_reverse_canonical_currencies {
    state $data = {};
    $data;
}

sub list_pairs {
    my ($self, %args) = @_;

    my $apires;
    eval { $apires = $self->{_client}->api_public(method => 'GetTradePairs') };
    return [500, "Died: $@"] if $@;

    my @res;
    for (@$apires) {
        my $pair;
        if ($args{native}) {
            $pair = $self->to_native_pair($_->{Label});
        } else {
            $pair = $self->to_canonical_pair($_->{Label});
        }
        push @res, {
            pair            => $pair,
            status          => $_->{Status}, # OK, Closing, Paused,
            status_detail   => $_->{StatusMessage},
            trade_fee       => $_->{TradeFee}, # in percent
            _id             => $_->{Id}, # e.g. 104 for LTC/BTC
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

    $pair =~ s!/!_!;

    my $apires;
    eval { $apires = $self->{_client}->api_public(
        method => "GetMarketOrders",
        parameters => [$pair],
    ) };
    return [500, "Died: $@"] if $@;

    $apires->{buy}  = delete $apires->{Buy};
    $apires->{sell} = delete $apires->{Sell};

    for (@{ $apires->{buy} }, @{ $apires->{sell} }) {
        $_ = [
            $_->{Price},
            $_->{Volume},
        ];
    }

    [200, "OK", $apires];
}

sub list_balances {
    my ($self, %args) = @_;

    my $apires;
    eval { $apires = $self->{_client}->api_private(
        method => "GetBalances",
        parameters => {},
    ) };
    return [500, "Died: $@"] if $@;

    my @recs;
    for (@$apires) {
        my $rec = {
            currency  => $self->to_canonical_currency($_->{Symbol}),
            available => $_->{Available},
            hold      => $_->{HeldForTrades},
            total     => $_->{Total},

            unconfirmed      => $_->{Unconfirmed},
            pending_withdraw => $_->{PendingWithdraw},
        };
    }

    [200, "OK", \@recs];
}

1;
# ABSTRACT: Interact with Cryptopia

=for Pod::Coverage ^(.+)$

=head1 SEE ALSO

Official Cryptopia API reference: L<Public
API|https://support.cryptopia.co.nz/csm?id=kb_article&sys_id=40e9c310dbf9130084ed147a3a9619eb>,
L<Private API|https://support.cryptopia.co.nz/csm?id=kb_article&sys_id=a75703dcdbb9130084ed147a3a9619bc>
