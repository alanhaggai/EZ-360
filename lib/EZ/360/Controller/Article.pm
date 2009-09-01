package EZ::360::Controller::Article;

use strict;
use warnings;
use parent 'Catalyst::Controller';

=head1 NAME

EZ::360::Controller::Article - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

sub create : Local : Args(0) {
    my ( $self, $c ) = @_;

    my $user_allowed = $c->user_exists()
      && $c->check_any_user_role(
        qw/ superuser
          can-create-article/
      );
    unless ($user_allowed) {
        $c->stash( error_message => 'Access denied' );
        $c->detach('/error');
    }

    if ( lc $c->request->method() eq 'post' ) {
        my $title   = $c->request->body_params->{'title'};
        my $content = $c->request->body_params->{'content'};

        my $error_message;

        if ( $title && $content ) {
            my $article;
            eval {
                $article = $c->model('DB::Article')->create(
                    {
                        title   => $title,
                        content => $content,
                    }
                );
            };

            if ($@) {
                $error_message = 'Error while creating article.';
            }
            else {
                $c->response->redirect(
                    $c->uri_for(
                        '/article/' . $article->id() . '/retrieve',
                        { status_message => 'Article created successfully.' }
                    )
                );

                return;
            }
        }

        $error_message ||= 'You did not provide a title, or a content.';
        $c->response->redirect(
            $c->uri_for( '/error', { error_message => $error_message } ) );
    }
    else {
        $c->stash( template => 'article/create.html' );
    }
}

sub list : Local : Args(0) {
    my ( $self, $c ) = @_;

    $c->stash(
        articles => [ $c->model('DB::Article')->all() ],
        template => 'article/list.html'
    );
}

sub id : Chained('/') : PathPart('article') : CaptureArgs(1) {
    my ( $self, $c, $id ) = @_;

    my $article = $c->model('DB::Article')->find($id);

    unless ($article) {
        $c->stash( status_message => 'Article does not exist.' );
        $c->detach('/error');
    }

    $c->stash( article => $article );
}

sub delete : Chained('id') : PathPart('delete') : Args(0) {
    my ( $self, $c ) = @_;

    my $user_allowed = $c->user_exists()
      && $c->check_any_user_role(
        qw/ superuser
          can-delete-article/
      );
    unless ($user_allowed) {
        $c->stash( error_message => 'Access denied' );
        $c->detach('/error');
    }

    if ( lc $c->request->method() eq 'post' ) {
        eval { $c->stash->{article}->delete(); };

        if ($@) {
            $c->response->redirect(
                $c->uri_for(
                    '/error',
                    {
                        error_message =>
                          'Error occurred while deleting article.'
                    }
                )
            );
        }
        else {
            $c->response->redirect(
                $c->uri_for(
                    '/article/list',
                    { status_message => 'Article deleted successfully.' }
                )
            );
        }
    }
    else {
        $c->stash( template => 'article/delete.html' );
    }
}

sub update : Chained('id') : PathPart('update') : Args(0) {
    my ( $self, $c ) = @_;

    my $user_allowed = $c->user_exists()
      && $c->check_any_user_role(
        qw/ superuser
          can-update-article/
      );
    unless ($user_allowed) {
        $c->stash( error_message => 'Access denied' );
        $c->detach('/error');
    }

    if ( lc $c->request->method() eq 'post' ) {
        my $title   = $c->request->body_params->{'title'};
        my $content = $c->request->body_params->{'content'};

        my $error_message;

        if ( $title && $content ) {
            my $article = $c->stash->{article};
            $article->title($title);
            $article->content($content);
            eval { $article->update(); };

            if ($@) {
                $error_message = 'Error while updating article.';
            }
            else {
                $c->response->redirect(
                    $c->uri_for(
                        '/article/' . $article->id() . '/retrieve',
                        { status_message => 'Article updated successfully.' }
                    )
                );

                return;
            }
        }

        $error_message ||= 'You did not provide a title, or a content.';
        $c->response->redirect(
            $c->uri_for( '/error', { error_message => $error_message } ) );
    }
    else {
        $c->stash( template => 'article/update.html' );
    }
}

sub retrieve : Chained('id') : PathPart('retrieve') : Args(0) {
    my ( $self, $c ) = @_;

    $c->stash( template => 'article/retrieve.html' );
}

=head1 AUTHOR

Alan Haggai Alavi

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
