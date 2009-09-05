package EZ::360::Controller::Link;

use strict;
use warnings;
use parent 'Catalyst::Controller';

=head1 NAME

EZ::360::Controller::Link - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

=head2 index

=cut

sub create : Local : Args(0) {
    my ( $self, $c ) = @_;

    $c->stash(
        articles => [ $c->model('DB::Article')->all() ],
        template => 'link/create.html'
    );
}

=head1 AUTHOR

Alan Haggai Alavi

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
