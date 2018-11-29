package App::cryp::Cmd::Exchange::ticker;

# DATE
# VERSION

use 5.010;
use strict;
use warnings;

require App::cryp::exchange;

our %SPEC;

$SPEC{handle_cmd} = $App::cryp::exchange::SPEC{ticker};
*handle_cmd = \&App::cryp::exchange::ticker;

1;
# ABSTRACT:
