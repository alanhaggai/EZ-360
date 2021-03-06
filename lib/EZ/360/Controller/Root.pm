package EZ::360::Controller::Root;

use strict;
use warnings;
use parent 'Catalyst::Controller';

#
# Sets the actions in this controller to be registered with no prefix
# so they function identically to actions created in MyApp.pm
#
__PACKAGE__->config->{namespace} = '';

=head1 NAME

EZ::360::Controller::Root - Root Controller for EZ::360

=head1 DESCRIPTION

[enter your description here]

=head1 METHODS

=cut

=head2 index

=cut

sub index : Path : Args(0) {
    my ( $self, $c ) = @_;

    $c->stash( template => 'index.html' );
}

sub default : Path {
    my ( $self, $c ) = @_;

    $c->response->status(404);
    $c->stash( template => '404.html' );
}

sub status : Local {
    my ( $self, $c ) = @_;

    $c->stash( template => 'status.html' );
}

sub check_user_roles : Private {
    my ( $self, $c, @roles ) = @_;

    unless ( $c->user_exists()
        && $c->check_any_user_role( 'superuser', @roles ) )
    {
        $c->stash( error_message => 'Access denied' );
        $c->detach('/status');
    }
}

=head2 end

Attempt to render a view, if needed.

=cut

sub end : ActionClass('RenderView') {
}

=head1 AUTHOR

Alan Haggai Alavi

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
