package EZ::360::Controller::User;

use strict;
use warnings;
use parent 'Catalyst::Controller';

=head1 NAME

EZ::360::Controller::User - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

sub create : Local : Args(0) {
    my ( $self, $c ) = @_;

    $c->stash( template => 'user/create.html' );
}

sub create_do : Path('create/do') : Args(0) {
    my ( $self, $c ) = @_;

    my $username           = $c->request->body_params->{'username'};
    my $password           = $c->request->body_params->{'password'};
    my $email              = $c->request->body_params->{'email'};
    my $realname           = $c->request->body_params->{'realname'};
    my $can_create_article = $c->request->body_params->{'can-create-article'};
    my $can_update_article = $c->request->body_params->{'can-update-article'};
    my $can_delete_article = $c->request->body_params->{'can-delete-article'};
    my $can_create_user    = $c->request->body_params->{'can-create-user'};
    my $can_update_user    = $c->request->body_params->{'can-update-user'};
    my $can_delete_user    = $c->request->body_params->{'can-delete-user'};
    my $superuser          = $c->request->body_params->{'superuser'};

    if ( $username && $password && $email ) {
        my $user;
        eval {
            $user = $c->model('DB::User')->create(
                {
                    username => $username,
                    password => $password,
                    email    => $email,
                    realname => $realname,
                }
            );
        };

        unless ($@) {
            $c->response->redirect(
                $c->uri_for(
                    '/user/' . $user->id() . '/retrieve',
                    { status_message => 'User created successfully.' }
                )
            );

            return;
        }
    }

    $c->response->redirect(
        $c->uri_for(
            '/error',
            { error_message => 'Error occurred while creating user.' }
        )
    );
}

sub id : Chained('/') : PathPart('user') : CaptureArgs(1) {
    my ( $self, $c, $id ) = @_;

    $c->stash( user => $c->model('DB::User')->find($id) );
}

=head1 AUTHOR

Alan Haggai Alavi

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
