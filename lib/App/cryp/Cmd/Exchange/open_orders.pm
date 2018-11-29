package App::cryp::Cmd::Exchange::open_orders;

# DATE
# VERSION

use 5.010;
use strict;
use warnings;

require App::cryp::exchange;

our %SPEC;

$SPEC{handle_cmd} = $App::cryp::exchange::SPEC{open_orders};
*handle_cmd = \&App::cryp::exchange::open_orders;

1;
# ABSTRACT:
