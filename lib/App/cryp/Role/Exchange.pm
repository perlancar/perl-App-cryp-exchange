package App::cryp::Role::Exchange;

# DATE
# VERSION

use 5.010001;
use strict;
use warnings;

use Role::Tiny;

requires qw(
               new

               data_canonical_currencies
               data_native_pair_separator
               list_balances
               list_pairs
       );

sub data_reverse_canonical_currencies {
    my $self = shift;

    return $self->{_reverse_canonical_currencies}
        if $self->{_reverse_canonical_currencies};

    $self->{_reverse_canonical_currencies} = {
        reverse %{ $self->data_canonical_currencies }
    };
}

sub to_canonical_currency {
    my ($self, $cur) = @_;
    $cur = uc $cur;
    my $cur2 = $self->data_canonical_currencies->{$cur};
    $cur2 // $cur;
}

sub to_native_currency {
    my ($self, $cur) = @_;
    $cur = uc $cur;
    my $cur2 = $self->data_reverse_canonical_currencies->{$cur};
    $cur2 // $cur;
}

sub to_canonical_pair {
    my ($self, $pair) = @_;

    my ($cur1, $cur2) = $pair =~ /([\w\$]+)[\W_]([\w\$]+)/
        or die "Invalid pair '$pair'";
    sprintf "%s/%s",
        $self->to_canonical_currency($cur1),
        $self->to_canonical_currency($cur2);
}

sub to_native_pair {
    my ($self, $pair) = @_;

    my ($cur1, $cur2) = $pair =~ /(\w+)[\W_](\w+)/
        or die "Invalid pair '$pair'";
    sprintf "%s%s%s",
        $self->to_native_currency($cur1),
        $self->data_native_pair_separator,
        $self->to_native_currency($cur2);
}

1;
# ABSTRACT: Role for interacting with an exchange

=head1 DESCRIPTION

This role describes the common API for interacting with an exchange that all
C<App::cryp::Exchange::*> modules follow.


=head1 ENVELOPED RESULT

All methods, unless specified otherwise, must return enveloped result:

 [$status, $reason, $payload, \%extra]

This result is analogous to an HTTP response; in fact C<$status> mostly uses
HTTP response codes. C<$reason> is analogous to HTTP status message. C<$payload>
is the actual content (optional if C<$status> is error status). C<%extra> is
optional and analogous to HTTP response headers to specify flags or attributes
or other metadata.

Some examples of enveloped result:

 [200, "OK", ["BTC/USD", "ETH/BTC"]]
 [404, "Not found"]

For more details about enveloped result, see L<Rinci::function>.


=head1 PROVIDED METHODS

=head2 to_canonical_currency

Usage:

 $xchg->to_canonical_currency($cur) => str

Convert native currency code to canonical/standardized currency code. Canonical
codes are listed in L<CryptoCurrency::Catalog>.

=head2 to_native_currency

Usage:

 $xchg->to_native_currency($cur) => str

Convert canonical/standardized currency code to exchange-native currency code.
Canonical codes are listed in L<CryptoCurrency::Catalog>.

=head2 to_canonical_pair

Usage:

 $xchg->to_canonical_pair($pair) => str

=head2 to_native_pair

Usage:

 $xchg->to_native_pair($pair) => str


=head1 REQUIRED METHODS

=head2 new

Usage:

 new(%args) => obj

Constructor. Known arguments:

=over

=item * api_key

String. Required.

=item * api_secret

String. Required.

=back

Some specific exchanges might require more credentials or arguments (e.g.
C<api_passphrase> on GDAX); please check with the specific drivers.

Method must return object.

=head2 data_native_pair_separator

Should return a single-character string.

=head2 data_canonical_currencies

Should return a hashref, a mapping between exchange-native currency codes to
canonical/standardized currency codes.

=head2 data_reverse_canonical_currencies

Returns hashref, a mapping of canonical/standardized currency codes to exchange
native codes. This role already provides an implementation, which calculates the
hashref by reversing the hash returned by C</"data_canonical_currencies"> and
caching the result in the instance's C<_reverse_canonical_currencies> key.
Driver can provide its own implementation.

=head2 list_balances

Usage:

 $xchg->list_balances(%args) => [$status, $reason, $payload, \%resmeta]

List account balances.

Method must return enveloped result. Payload must be an array of hashrefs. Each
hashref must contain at least these keys: C<currency> (fiat_or_crpytocurrency),
C<available> (num, balance available for trading i.e. buying), C<hold> (num,
balance that is currently held so not available for trading, e.g. balance on
currently open buy orders). C<total> (num, should be C<available> + C<hold>).
Hashref may contain additional keys.

=head2 list_pairs

Usage:

 $xchg->list_pairs(%args) => [$status, $reason, $payload, \%resmeta]

List all pairs available for trading.

Method must return enveloped result. Payload must be an array containing pair
names (except when C<detail> argument is set to true, in which case method must
return array of records/hashrefs).

Pair names must be in the form of I<< <currency1>/<currency2> >> where
I<currency1> is cryptocurrency code and I<< <currency2> >> is the base currency
code (fiat or crypto). Some example pair names: BTC/USD, ETH/BTC.

Known arguments:

=over

=item * native

Boolean. Default 0. If set to 1, method must return pair codes in native
exchange form instead of canonical/standardized form.

=item * detail

Boolean. Default 0. If set to 1, method must return array of records/hashrefs
instead of just array of strings (pair names).

Record must contain these keys: C<name> (pair name, str). Record can contain
additional keys.

=back

=head2 get_order_book

Usage:

 $xchg->get_order_book(%args) => [$status, $reason, $payload, \%resmeta]

Method should return this payload:

 {
     buy => [
         [100, 10 ] , # price, amount
         [ 99,  4.1], # price, amount
         ...
     ],
     sell => [
         [101  , 5.5], # price, amount
         [101.5, 3.1], # price, amount
         ...
     ],
 }

Buy (bid, purchase) records must be sorted from highest price to lowest price.
Sell (ask, offer) records must be sorted from lowest price to highest.

Known arguments:

=over

=item * pair

String. Pair.

=back


=head1 SEE ALSO
