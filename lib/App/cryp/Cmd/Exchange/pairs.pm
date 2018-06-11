package App::cryp::Cmd::Exchange::pairs;

# DATE
# VERSION

use 5.010;
use strict;
use warnings;

require App::cryp::exchange;

our %SPEC;

$SPEC{handle_cmd} = $App::cryp::exchange::SPEC{pairs};
*handle_cmd = \&App::cryp::exchange::pairs;

1;
# ABSTRACT:
