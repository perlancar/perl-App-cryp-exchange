package App::cryp::Cmd::Exchange::get_order;

# DATE
# VERSION

use 5.010;
use strict;
use warnings;

require App::cryp::exchange;

our %SPEC;

$SPEC{handle_cmd} = $App::cryp::exchange::SPEC{get_order};
*handle_cmd = \&App::cryp::exchange::get_order;

1;
# ABSTRACT:
