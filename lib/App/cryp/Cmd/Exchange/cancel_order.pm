package App::cryp::Cmd::Exchange::cancel_order;

# DATE
# VERSION

use 5.010;
use strict;
use warnings;

require App::cryp::exchange;

our %SPEC;

$SPEC{handle_cmd} = $App::cryp::exchange::SPEC{cancel_order};
*handle_cmd = \&App::cryp::exchange::cancel_order;

1;
# ABSTRACT:
