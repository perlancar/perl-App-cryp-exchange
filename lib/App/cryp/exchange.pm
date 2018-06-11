package App::cryp::exchange;

# DATE
# VERSION

use 5.010001;
use strict;
use warnings;
use Log::ger;

our %SPEC;

our %arg_detail = (
    detail => {
        schema => 'bool*',
        cmdline_aliases => {l=>{}},
    },
);

our %arg_native = (
    native => {
        schema => 'bool*',
    },
);

our %arg_req0_account = (
    account => {
        schema => 'cryptoexchange::account*',
        req => 1,
        pos => 0,
    },
);

our %arg_req1_pair = (
    pair => {
        schema => 'str*',
        # XXX completion
        req => 1,
        pos => 1,
    },
);

our %arg_type = (
    type => {
        schema => ['str*', in=>['buy','sell']],
        tags => ['category:filtering'],
        cmdline_aliases => {
            buy  => {is_flag=>1, code=>sub {$_[0]{type}='buy' }, summary=>'Alias for --type=buy' },
            sell => {is_flag=>1, code=>sub {$_[0]{type}='sell'}, summary=>'Alias for --type=sell'},
        },
    },
);

$SPEC{':package'} = {
    v => 1.1,
    summary => 'Interact with cryptoexchanges using a common interface',
};

sub _init {
    my ($r) = @_;

  INSTANTIATE_EXCHANGE_CLIENT:
    {
        last unless $r->{args}{account};
        my ($exchange, $account) = $r->{args}{account} =~ m!(.+)/(.+)!
            or return [
                400, "Invalid cryptoexchange account syntax ".
                    "'$r->{args}{account}', please use EXCHANGE/ACCOUNT ".
                    "format"];
        my $mod = "App::cryp::Exchange::$exchange"; $mod =~ s/-/_/g;
        (my $mod_pm = "$mod.pm") =~ s!::!/!g; require $mod_pm;

        my $hash = $r->{_cryp}{exchanges}{$exchange}{$account}
            or return [404, "Unknown $exchange account $account"];

        my %args = map { $_ => $hash->{$_} } grep {/^api_/} keys %$hash;

        $r->{_stash}{exchange_client} = $mod->new(%args);
    }
    [200];
}

$SPEC{exchanges} = {
    v => 1.1,
    summary => 'List supported exchanges',
    args => {
        %arg_detail,
    },
    tags => ['category:etc'],
};
sub exchanges {
    require PERLANCAR::Module::List;

    my %args = @_;

    my $mods = PERLANCAR::Module::List::list_modules(
        "App::cryp::Exchange::", {list_modules=>1});

    my @res;
    for my $mod (sort keys %$mods) {
        my ($safename) = $mod =~ /::(\w+)\z/;
        $safename =~ s/_/-/g;
        push @res, {
            safename => $safename,
        };
    }

    unless ($args{detail}) {
        @res = map {$_->{safename}} @res;
    }

    my $resmeta = {
    };

    [200, "OK", \@res, $resmeta];
}

$SPEC{accounts} = {
    v => 1.1,
    summary => 'List exchange accounts',
    args => {
        # XXX filter by exchange (-I, -X)
        %arg_detail,
    },
    tags => ['category:etc'],
};
sub accounts {
    my %args = @_;

    my $crypconf = $args{-cmdline_r}{_cryp};

    my @res;
    for my $safename (sort keys %{$crypconf->{exchanges}}) {
        my $c = $crypconf->{exchanges}{$safename};

        for my $account (sort keys %$c) {
            push @res, {
                exchange => $safename,
                account  => $account,
            };
        }
    }

    unless ($args{detail}) {
        @res = map { "$_->{exchange}/$_->{account}" } @res;
    }

    my $resmeta = {
        'table.fields' => [qw/exchange account/],
    };

    [200, "OK", \@res, $resmeta];

}

$SPEC{pairs} = {
    v => 1.1,
    summary => 'List pairs supported by exchange',
    args => {
        %arg_req0_account,
        %arg_detail,
        %arg_native,
    },
};
sub pairs {
    my %args = @_;

    my $r = $args{-cmdline_r};

    my $res = _init($r); return $res unless $res->[0] == 200;
    my $xchg = $r->{_stash}{exchange_client};

    $xchg->list_pairs(
        detail => $args{detail},
        native => $args{native},
    );
}

$SPEC{orderbook} = {
    v => 1.1,
    summary => 'Get order book on an exchange',
    args => {
        %arg_req0_account,
        %arg_req1_pair,
        %arg_type,
    },
};
sub orderbook {
    my %args = @_;

    my $r = $args{-cmdline_r};

    my $res = _init($r); return $res unless $res->[0] == 200;
    my $xchg = $r->{_stash}{exchange_client};

    $res = $xchg->get_order_book(
        pair => $args{pair},
    );
    return $res unless $res->[0] == 200;

    # display in a 2d table format which is more user-friendly for cli user
    my @rows;
    {
        last if $args{type} && $args{type} ne 'buy';
        for my $rec (@{ $res->[2]{buy} }) {
            push @rows, {
                type   => "buy",
                price  => $rec->[0],
                amount => $rec->[1],
            };
        }
    }

    {
        last if $args{type} && $args{type} ne 'sell';
        for my $rec (@{ $res->[2]{sell} }) {
            push @rows, {
                type   => "sell",
                price  => $rec->[0],
                amount => $rec->[1],
            };
        }
    }

    [200, "OK", \@rows];
}

$SPEC{balance} = {
    v => 1.1,
    summary => 'List account balance',
    args => {
        %arg_req0_account,
    },
};
sub balance {
    my %args = @_;

    my $r = $args{-cmdline_r};

    my $res = _init($r); return $res unless $res->[0] == 200;
    my $xchg = $r->{_stash}{exchange_client};

    $xchg->list_balances;
}

1;
# ABSTRACT:

=head1 SYNOPSIS

Please see included script L<cryp-exchange>.


=head1 SEE ALSO

Other C<App::cryp::*> modules.
