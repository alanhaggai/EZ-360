package EZ::360::View::Web;

use strict;
use base 'Catalyst::View::TT';

__PACKAGE__->config(
    INCLUDE_PATH => [ EZ::360->path_to( 'root', 'src' ) ],
    WRAPPER      => 'wrapper.html',
);

=head1 NAME

EZ::360::View::Web - TT View for EZ::360

=head1 DESCRIPTION

TT View for EZ::360. 

=head1 SEE ALSO

L<EZ::360>

=head1 AUTHOR

Alan Haggai Alavi

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
