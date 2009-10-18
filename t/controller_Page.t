use strict;
use warnings;
use Test::More tests => 3;

BEGIN { use_ok 'Catalyst::Test', 'EZ::360' }
BEGIN { use_ok 'EZ::360::Controller::Page' }

ok( request('/page')->is_success, 'Request should succeed' );


