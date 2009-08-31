package EZ::360::Controller::Login;

use strict;
use warnings;
use parent 'Catalyst::Controller';

=head1 NAME

EZ::360::Controller::Login - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

=head2 index

=cut

sub index : Path : Args(0) {
    my ( $self, $c ) = @_;

    $c->stash( template => 'login.html' );
}

sub login_do : Path('do') : Args(0) {
    my ( $self, $c ) = @_;

    my $username = $c->request->body_params->{'username'};
    my $password = $c->request->body_params->{'password'};

    if (
        $c->authenticate(
            {
                username => $username,
                password => $password,
            }
        )
      )
    {
        $c->response->redirect( $c->uri_for('/',
            { status_message => 'You have logged in successfully.' } ) );
    }
    else {
        $c->response->redirect(
            $c->uri_for(
                '/error/',
                {
                    error_message =>
                      'The username or password you entered is incorrect.'
                }
            )
        );
    }
}

=head1 AUTHOR

Alan Haggai Alavi

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
