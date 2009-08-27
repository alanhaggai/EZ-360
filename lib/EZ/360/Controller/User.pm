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

    my $username = $c->request->body_params->{'username'};
    my $password = $c->request->body_params->{'password'};
    my $email    = $c->request->body_params->{'email'};
    my $realname = $c->request->body_params->{'realname'};
    my %roles    = (
        'can-create-article' =>
          $c->request->body_params->{'can-create-article'},
        'can-update-article' =>
          $c->request->body_params->{'can-update-article'},
        'can-delete-article' =>
          $c->request->body_params->{'can-delete-article'},
        'can-create-user' => $c->request->body_params->{'can-create-user'},
        'can-update-user' => $c->request->body_params->{'can-update-user'},
        'can-delete-user' => $c->request->body_params->{'can-delete-user'},
        'superuser'       => $c->request->body_params->{'superuser'},
    );

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

            for ( keys %roles ) {
                next unless defined $roles{$_};
                my $role_id =
                  $c->model('DB::Role')->search( { role => $_ } )->first()
                  ->id();
                $user->add_to_user_role( { role_id => $role_id } );
            }
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
            '/error', { error_message => 'Error occurred while creating user.' }
        )
    );
}

sub id : Chained('/') : PathPart('user') : CaptureArgs(1) {
    my ( $self, $c, $id ) = @_;

    $c->stash( user => $c->model('DB::User')->find($id) );
}

sub update : Chained('id') : PathPart('update') : Args(0) {
    my ( $self, $c, $id ) = @_;

    my $user = $c->stash->{user};
    unless ($user) {
        $c->stash( status_message =>
              'Error occurred while trying to update nonexistent user.' );
        $c->detach('/error');
    }

    my @roles;
    for ( $c->model('DB::Role')->all() ) {
        my $role_status;
        for my $user_role ( $user->roles() ) {
            if ( $_->role() eq $user_role->role() ) {
                $role_status = q{checked='checked'};
                last;
            }
        }
        my $text = $_->role();
        $text =~ s/-/ /g;
        push @roles, { text => $text, role => $_->role(), status => $role_status };
    }

    $c->stash(
        roles    => \@roles,
        template => 'user/update.html',
    );
}

sub retrieve : Chained('id') : PathPart('retrieve') : Args(0) {
    my ( $self, $c ) = @_;

    unless ( $c->stash->{user} ) {
        $c->stash( status_message => 'Error occurred while retrieving user.' );
        $c->detach('/error');
    }

    $c->stash( template => 'user/retrieve.html' );
}

=head1 AUTHOR

Alan Haggai Alavi

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
