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

    # Get all existing roles to display checkboxes for each.
    # Beautify text displayed for roles by removing hyphens.
    my @roles;
    for ( $c->model('DB::Role')->all() ) {
        my $text = $_->role();
        $text =~ s/-/ /g;
        push @roles, { text => $text, role => $_->role() };
    }

    $c->stash(
        roles    => \@roles,
        template => 'user/create.html',
    );
}

sub create_do : Path('create/do') : Args(0) {
    my ( $self, $c ) = @_;

    my $username = $c->request->body_params->{'username'};
    my $password = $c->request->body_params->{'password'};
    my $email    = $c->request->body_params->{'email'};
    my $realname = $c->request->body_params->{'realname'};

    my %roles;
    for ( $c->model('DB::Role')->all() ) {
        $roles{ $_->role() } = $c->request->body_params->{ $_->role() };
    }

    my $error_message;

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

        if ($@) {
            $error_message = 'Error while creating user.';
        }
        else {

            # Add to table `user_role` the roles that have been assigned to the
            # user.
            for ( keys %roles ) {
                next unless $roles{$_} eq 'on';

                my $role_id =
                  $c->model('DB::Role')->search( { role => $_ } )->first()
                  ->id();
                $user->add_to_user_role( { role_id => $role_id } );
            }

            $c->response->redirect(
                $c->uri_for(
                    '/user/' . $user->id() . '/retrieve',
                    { status_message => 'User created successfully.' }
                )
            );

            return;
        }
    }

    $error_message ||= 'You did not provide a username, password or e-mail.';
    $c->response->redirect(
        $c->uri_for( '/error', { error_message => $error_message } ) );
}

sub id : Chained('/') : PathPart('user') : CaptureArgs(1) {
    my ( $self, $c, $id ) = @_;

    my $user = $c->model('DB::User')->find($id);
    unless ($user) {
        $c->stash( status_message => 'User does not exist.' );
        $c->detach('/error');
    }
    $c->stash( user => $user );
}

sub update : Chained('id') : PathPart('update') : Args(0) {
    my ( $self, $c, $id ) = @_;

    my $user = $c->stash->{user};

    # Get all roles and select the ones that the user has.
    my @roles;
    for ( $c->model('DB::Role')->all() ) {
        my $role_status;
        for my $user_role ( $user->roles() ) {
            if ( $_->role() eq $user_role->role() ) {
                $role_status = q{checked='checked'};
                last;
            }
        }

        # Beautify the display of roles by showing them without hyphens.
        my $text = $_->role();
        $text =~ s/-/ /g;

        push @roles,
          { text => $text, role => $_->role(), status => $role_status };
    }

    $c->stash(
        roles    => \@roles,
        template => 'user/update.html',
    );
}

sub update_do : Chained('id') : PathPart('update/do') : Args(0) {
    my ( $self, $c, $id ) = @_;

    my $user = $c->stash->{user};

    my $username         = $c->request->body_params->{'username'};
    my $password         = $c->request->body_params->{'password'};
    my $confirm_password = $c->request->body_params->{'confirm-password'};
    my $email            = $c->request->body_params->{'email'};
    my $realname         = $c->request->body_params->{'realname'};

    my %roles;
    for ( $c->model('DB::Role')->all() ) {
        $roles{ $_->role() } = $c->request->body_params->{ $_->role() };
    }

    my $error_message;

    if (   $username
        && $password
        && $email
        && ( $password eq $confirm_password ) )
    {
        eval {
            $user->update(
                {
                    username => $username,
                    password => $password,
                    email    => $email,
                    realname => $realname,
                }
            );
        };

        if ($@) {
            $error_message = 'Error while updating user.';
        }
        else {
            $user->user_role->delete();

            # Add to table `user_role` the roles that have been assigned to the
            # user.
            for ( keys %roles ) {
                next unless $roles{$_} eq 'on';

                my $role_id =
                  $c->model('DB::Role')->search( { role => $_ } )->first()
                  ->id();
                $user->add_to_user_role( { role_id => $role_id } );
            }

            $c->response->redirect(
                $c->uri_for(
                    '/user/' . $user->id() . '/retrieve',
                    { status_message => 'User updated successfully.' }
                )
            );

            return;
        }
    }

    $error_message ||=
      'You did not provide a username, e-mail, or failed to confirm password.';
    $c->response->redirect(
        $c->uri_for( '/error', { error_message => $error_message } ) );
}

sub delete : Chained('id') : PathPart('delete') : Args(0) {
    my ( $self, $c ) = @_;

    $c->stash( template => 'user/delete.html' );
}

sub delete_do : Chained('id') : PathPart('delete/do') : Args(0) {
    my ( $self, $c ) = @_;

    eval { $c->stash->{user}->delete(); };

    if ($@) {
        $c->response->redirect(
            $c->uri_for(
                '/error',
                { error_message => 'Error occurred while deleting user.' }
            )
        );
    }
}

sub retrieve : Chained('id') : PathPart('retrieve') : Args(0) {
    my ( $self, $c ) = @_;

    my @roles;
    for ( $c->stash->{user}->roles() ) {
        my $text = $_->role();
        $text =~ s/-/ /g;
        push @roles, $text;
    }

    $c->stash(
        roles    => \@roles,
        template => 'user/retrieve.html'
    );
}

=head1 AUTHOR

Alan Haggai Alavi

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
