package App::cryp::Cmd::Exchange::orderbook;

# DATE
# VERSION

use 5.010;
use strict;
use warnings;

require App::cryp::exchange;

our %SPEC;

$SPEC{handle_cmd} = $App::cryp::exchange::SPEC{orderbook};
*handle_cmd = \&App::cryp::exchange::orderbook;

1;
# ABSTRACT:
