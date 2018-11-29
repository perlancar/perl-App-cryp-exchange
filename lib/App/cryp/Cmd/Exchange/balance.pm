package App::cryp::Cmd::Exchange::balance;

# DATE
# VERSION

use 5.010;
use strict;
use warnings;

require App::cryp::exchange;

our %SPEC;

$SPEC{handle_cmd} = $App::cryp::exchange::SPEC{balance};
*handle_cmd = \&App::cryp::exchange::balance;

1;
# ABSTRACT:
