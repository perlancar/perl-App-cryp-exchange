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

our %arg_req0_exchange = (
    exchange => {
        schema => 'str*',
        completion => sub {
            require Complete::Util;

            my %args = @_;

            my $mods = PERLANCAR::Module::List::list_modules(
                "App::cryp::Exchange::", {list_modules=>1});

            my @safenames;
            for (sort keys %mods) {
                s/.+:://;
                s/_/-/g;
                push @safename, $_;
            }

            Complete::Util::complete_array_elem(
                word  => $args{word},
                array => \@safenames,
            );
        },
        req => 1,
        pos => 0,
    },
);

$SPEC{':package'} = {
    v => 1.1,
    summary => 'Interact with cryptoexchanges',
};

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
    },
};
sub list_pairs {
    my %args = @_;
}

1;
# ABSTRACT:

=head1 SYNOPSIS

Please see included script L<cryp-mn>.


=head1 SEE ALSO

L<App::cryp> and other C<App::cryp::*> modules.
