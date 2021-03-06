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

    $c->forward('/check_user_roles');

    if ( lc $c->request->method() eq 'post' ) {
        my $username = $c->request->body_params->{'username'};
        my $password = $c->request->body_params->{'password'};
        my $email    = $c->request->body_params->{'email'};
        my $realname = $c->request->body_params->{'realname'};
        my $roles    = $c->request->body_params->{'role'};

        my $status_message;
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
                $user->set_all_roles($roles);
            };

            if ($@) {
                $status_message = 'Error while creating user.';
            }
            else {
                $c->response->redirect(
                    $c->uri_for(
                        '/user/' . $user->id() . '/retrieve',
                        { success_message => 'User created successfully.' }
                    )
                );
                return;
            }
        }
        else {
            $status_message ||= 'Username, password or e-mail not provided';
            $c->response->redirect(
                $c->uri_for( '/status', { notice_message => $status_message } )
            );
        }
    }
    else {
        $c->stash(
            roles_rs => $c->model('DB::Role'),
            template => 'user/create.html',
        );
    }
}

sub list : Local : Args(0) {
    my ( $self, $c ) = @_;

    $c->forward( '/check_user_roles', [qw/user/] );

    $c->stash(
        users_rs => $c->model('DB::User'),
        template => 'user/list.html'
    );
}

sub id : Chained('/') : PathPart('user') : CaptureArgs(1) {
    my ( $self, $c, $id ) = @_;

    my $user = $c->model('DB::User')->find($id);
    unless ($user) {
        $c->stash( notice_message => 'User does not exist.' );
        $c->detach('/status');
    }
    $c->stash( user => $user );
}

sub update : Chained('id') : PathPart('update') : Args(0) {
    my ( $self, $c ) = @_;

    my $user = $c->stash->{user};

    if ( $c->user->id() != $user->id() ) {
        $c->forward('/check_user_roles');
    }

    if ( lc $c->request->method() eq 'post' ) {
        my $username         = $c->request->body_params->{'username'};
        my $password         = $c->request->body_params->{'password'};
        my $confirm_password = $c->request->body_params->{'confirm-password'};
        my $email            = $c->request->body_params->{'email'};
        my $realname         = $c->request->body_params->{'realname'};
        my $roles            = $c->request->body_params->{'role'};

        my $error_message;
        if (   $username
            && $email
            && ( $password eq $confirm_password ) )
        {
            eval {
                $user->update(
                    {
                        username => $username,
                        email    => $email,
                        realname => $realname,
                    }
                );
                $user->update( { password => $password } ) if $password;
                $user->set_all_roles($roles) if $c->check_any_user_role(
                    qw/
                      superuser can-update-user/
                );
            };

            if ($@) {
                $error_message = 'Error while updating user.';
            }
            else {
                $c->response->redirect(
                    $c->uri_for(
                        '/user/' . $user->id() . '/retrieve',
                        { success_message => 'User updated successfully.' }
                    )
                );

                return;
            }
        }

        $error_message ||=
          'Username or e-mail not provided or failed to confirm password';
        $c->response->redirect(
            $c->uri_for( '/status', { error_message => $error_message } ) );
    }
    else {
        $c->stash(
            roles_rs => $c->model('DB::Role'),
            template => 'user/update.html',
        );
    }
}

sub delete : Chained('id') : PathPart('delete') : Args(0) {
    my ( $self, $c ) = @_;

    $c->forward('/check_user_roles');

    if ( lc $c->request->method() eq 'post' ) {
        eval { $c->stash->{user}->delete(); };

        if ($@) {
            $c->response->redirect(
                $c->uri_for(
                    '/status',
                    { error_message => 'Error occurred while deleting user.' }
                )
            );
        }
        else {
            $c->response->redirect(
                $c->uri_for(
                    '/user/list',
                    { success_message => 'User deleted successfully.' }
                )
            );
        }
    }
    else {
        $c->stash( template => 'user/delete.html' );
    }

}

sub retrieve : Chained('id') : PathPart('retrieve') : Args(0) {
    my ( $self, $c ) = @_;

    $c->forward( '/check_user_roles', [qw/user/] );

    $c->stash( template => 'user/retrieve.html' );
}

=head1 AUTHOR

Alan Haggai Alavi

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
