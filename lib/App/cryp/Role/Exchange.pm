package App::cryp::Role::Exchange;

# DATE
# VERSION

use 5.010001;
use strict;
use warnings;

use Role::Tiny;

requires qw(
               list_pairs
               data_canonical_currencies
               data_reverse_canonical_currencies
       );

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
}

sub to_native_pair {
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

=head2


=head1 REQUIRED METHODS

=head2 new

Usage:

  new(%args) => obj

Constructor. Known arguments:

=over

=item * api_key

=item * api_secret

=back

Method must return object.

=head2 list_pairs

Usage: $xchg->list_pairs => [$status, $reason, $payload, \%resmeta]

List all pairs available for trading.

Method must return enveloped result. Payload must be an array containing pair
names (except when C<detail> argument is set to true, in which case method must
return array of records/hashrefs).

Pair names must be in the form of I<< <currency1>/<currency2> >> where I<<
<currency2> >> is the base currency symbol. Currency symbols must follow list in
L<CryptoCurrency::Catalog>. Some example pair names: BTC/USD, ETH/BTC.

Known options:

=over

=item * detail

Boolean. Default 0. If set to 1, method must return array of records/hashrefs
instead of just array of strings (pair names).

Record must contain these keys: C<name> (pair name, str). Record can contain
additional keys.

=back



=head1 SEE ALSO
