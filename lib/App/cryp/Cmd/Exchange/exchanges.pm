package App::cryp::Cmd::Exchange::exchanges;

# DATE
# VERSION

use 5.010;
use strict;
use warnings;

require App::cryp::exchange;

our %SPEC;

$SPEC{handle_cmd} = $App::cryp::exchange::SPEC{exchanges};
*handle_cmd = \&App::cryp::exchange::exchanges;

1;
# ABSTRACT:
