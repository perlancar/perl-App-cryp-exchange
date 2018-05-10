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

sub data_canonical_currencies {
    state $data = do {
        require App::indodax;
        my %hash = %App::indodax::Canonical_Currencies;
        for my $k (keys %hash) {
            $hash{uc $k} = uc(delete $hash{$k});
        }
        \%hash;
    };
    $data;
}

sub data_reverse_canonical_currencies {
    state $data = do {
        require App::indodax;
        my %hash = %App::indodax::Rev_Canonical_Currencies;
        for my $k (keys %hash) {
            $hash{uc $k} = uc(delete $hash{$k});
        }
        \%hash;
    };
    $data;
}

sub list_pairs {
    my ($self, %args) = @_;

    require App::indodax;
    # XXX in the future, we will put the master data here instead of in
    # App::indodax

    my $res = App::indodax::pairs();
    return $res unless $res->[0] == 200;

    my @res;
    for (@{ $res->[2] }) {
        if ($args{native}) {
            $_ = lc $self->to_native_pair($_);
        } else {
            $_ = $self->to_canonical_pair($_);
        }
        push @res, {
            pair => $_,
        };
    }

    unless ($args{detail}) {
        @res = map { $_->{pair} } @res;
    }

    [200, "OK", \@res];
}

sub get_order_book {
    my ($self, %args) = @_;

    my $pair = lc $self->to_native_pair($args{pair});

    my $res;
    eval { $res = $self->{_client}->get_depth(pair => $pair) };
    return [500, "Died: $@"] if $@;

    [200, "OK", $res];
}

1;
# ABSTRACT: Interact with Indodax

=for Pod::Coverage ^(.+)$
