package App::cryp::Cmd::Exchange::create_limit_order;

# DATE
# VERSION

use 5.010;
use strict;
use warnings;

require App::cryp::exchange;

our %SPEC;

$SPEC{handle_cmd} = $App::cryp::exchange::SPEC{create_limit_order};
*handle_cmd = \&App::cryp::exchange::create_limit_order;

1;
# ABSTRACT:
