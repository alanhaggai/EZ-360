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

    $c->stash( template => 'article/create.html' );
}

sub create_do : Path('create/do') : Args(0) {
    my ( $self, $c ) = @_;

    my $title   = $c->request->body_params->{'title'};
    my $content = $c->request->body_params->{'content'};

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

        unless ($@) {
            $c->response->redirect(
                $c->uri_for(
                    '/article/' . $article->id() . '/retrieve',
                    { status_message => 'Article created successfully.' }
                )
            );

            return;
        }
    }

    $c->response->redirect(
        $c->uri_for(
            '/error',
            { error_message => 'Error occurred while creating article.' }
        )
    );
}

sub id : Chained('/') : PathPart('article') : CaptureArgs(1) {
    my ( $self, $c, $id ) = @_;

    $c->stash( article => $c->model('DB::Article')->find($id) );
}

sub delete : Chained('id') : PathPart('delete') : Args(0) {
    my ( $self, $c ) = @_;

    $c->stash( template => 'article/delete.html' );
}

sub delete_do : Chained('id') : PathPart('delete/do') : Args(0) {
    my ( $self, $c ) = @_;

    my $article = $c->stash->{article};
    eval { $article->delete(); };

    if ($@) {
        $c->response->redirect(
            $c->uri_for(
                '/error',
                { error_message => 'Error occurred while deleting article.' }
            )
        );
    }
}

sub update : Chained('id') : PathPart('update') : Args(0) {
    my ( $self, $c ) = @_;

    $c->stash( template => 'article/update.html' );
}

sub update_do : Chained('id') : PathPart('update/do') : Args(0) {
    my ( $self, $c ) = @_;

    my $title   = $c->request->body_params->{'title'};
    my $content = $c->request->body_params->{'content'};

    if ( $title && $content ) {
        my $article = $c->stash->{article};
        eval {
            $article->title($title);
            $article->content($content);
            $article->update();
        };

        unless ($@) {
            $c->response->redirect(
                $c->uri_for(
                    '/article/' . $article->id() . '/retrieve',
                    { status_message => 'Article updated successfully.' }
                )
            );

            return;
        }
    }

    $c->response->redirect(
        $c->uri_for(
            '/error',
            { error_message => 'Error occurred while updating article.' }
        )
    );
}

sub retrieve : Chained('id') : PathPart('retrieve') : Args(0) {
    my ( $self, $c ) = @_;

    unless ( $c->stash->{article} ) {
        $c->stash(
            status_message => 'Error occurred while retrieving article.' );
        $c->detach('/error');
    }

    $c->stash( template => 'article/retrieve.html' );
}

=head1 AUTHOR

Alan Haggai Alavi

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
