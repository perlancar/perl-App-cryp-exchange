package App::cryp::exchange;

# DATE
# VERSION

use 5.010001;
use strict;
use warnings;
use Log::ger;

our %SPEC;

our $_complete_exchange = sub {
    require Complete::Util;

    my %args = @_;

    my $mods = PERLANCAR::Module::List::list_modules(
        "App::cryp::Exchange::", {list_modules=>1});

    my @safenames;
    for (sort keys %$mods) {
        s/.+:://;
        s/_/-/g;
        push @safenames, $_;
    }

    Complete::Util::complete_array_elem(
        word  => $args{word},
        array => \@safenames,
    );
};

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

our %arg_req0_exchange = (
    exchange => {
        schema => 'str*',
        completion => $_complete_exchange,
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
    summary => 'Interact with cryptoexchanges',
};

sub _instantiate_exchange {
    my ($r, $exchange, $account) = @_;

    my $mod = "App::cryp::Exchange::$exchange"; $mod =~ s/-/_/g;
    (my $mod_pm = "$mod.pm") =~ s!::!/!g; require $mod_pm;

    my $crypconf = $r->{_cryp};

    my %args = (
    );

    my $accounts = $crypconf->{exchanges}{$exchange} // {};
    for my $a (sort keys %$accounts) {
        if (!defined($account) || $account eq $a) {
            for (grep {/^api_/} keys %{ $accounts->{$a} }) {
                $args{$_} = $accounts->{$a}{$_};
            }
            last;
        }
    }
    $mod->new(%args);
}

$SPEC{list_exchanges} = {
    v => 1.1,
    summary => 'List supported exchanges',
    args => {
        %arg_detail,
    },
};
sub list_exchanges {
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

$SPEC{list_accounts} = {
    v => 1.1,
    summary => 'List exchange accounts',
    args => {
        # XXX filter by exchnage (-I, -X)
        %arg_detail,
    },
};
sub list_accounts {
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

$SPEC{list_pairs} = {
    v => 1.1,
    summary => 'List pairs supported by exchange',
    args => {
        %arg_req0_exchange,
        %arg_detail,
        %arg_native,
    },
};
sub list_pairs {
    my %args = @_;

    my $r = $args{-cmdline_r};

    my $xchg = _instantiate_exchange($r, $args{exchange});

    $xchg->list_pairs(
        detail => $args{detail},
        native => $args{native},
    );
}

$SPEC{get_order_book} = {
    v => 1.1,
    summary => 'Get order book on an exchange',
    args => {
        %arg_req0_exchange,
        %arg_req1_pair,
        %arg_type,
    },
};
sub get_order_book {
    my %args = @_;

    my $r = $args{-cmdline_r};

    my $xchg = _instantiate_exchange($r, $args{exchange});

    $xchg->get_order_book(
        pair => $args{pair},
        type => $args{type},
    );
}


1;
# ABSTRACT:

=head1 SYNOPSIS

Please see included script L<cryp-exchange>.


=head1 SEE ALSO

Other C<App::cryp::*> modules.
