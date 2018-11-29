package App::cryp::Cmd::Exchange::accounts;

# DATE
# VERSION

use 5.010;
use strict;
use warnings;

require App::cryp::exchange;

our %SPEC;

$SPEC{handle_cmd} = $App::cryp::exchange::SPEC{accounts};
*handle_cmd = \&App::cryp::exchange::accounts;

1;
# ABSTRACT:
