package EZ::360::Controller::Page;

use strict;
use warnings;
use parent 'Catalyst::Controller';

=head1 NAME

EZ::360::Controller::Page - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

=head2 index

=cut

sub create : Local : Args(0) {
    my ( $self, $c ) = @_;

    if ( lc $c->request->method() eq 'post' ) {
        my $title           = $c->request->body_params->{'title'};
        my $articles_string = $c->request->body_params->{'articles-string'};
        my $parent          = $c->request->body_params->{'parent'};

        my @articles = split /\s/, $articles_string;

        my $status_message;
        if ( $title && @articles ) {
            my $page;
            eval {
                $page = $c->model('DB::Page')->create( { title => $title } );
                for (@articles) {
                    $page->create_related( 'article', { article_id => $_ } );
                }
                $c->model('DB::PageRelation')
                  ->create( { page_id => $parent, child => $page->id() } );
            };

            if ($@) {
                $status_message = 'Error while creating page.';
            }
            else {
                $c->response->redirect(
                    $c->uri_for(
                        '/page/' . $page->id() . '/retrieve',
                        { success_message => 'Page created successfully.' }
                    )
                );

                return;
            }
        }

        $status_message ||= 'Title or articles not provided';
        $c->response->redirect(
            $c->uri_for( '/status', { notice_message => $status_message } ) );
    }

    $c->stash(
        articles => [ $c->model('DB::Article')->all() ],
        pages    => [ $c->model('DB::Page')->all() ],
        template => 'page/create.html',
    );
}

sub list : Local : Args(0) {
    my ( $self, $c ) = @_;

    $c->stash(
        pages    => [ $c->model('DB::Page')->all() ],
        template => 'page/list.html'
    );
}

sub id : Chained('/') : PathPart('page') : CaptureArgs(1) {
    my ( $self, $c, $id ) = @_;

    my $page = $c->model('DB::Page')->find($id);

    unless ($page) {
        $c->stash( notice_message => 'Page does not exist' );
        $c->detach('/status');
    }

    $c->stash( page => $page );
}

sub retrieve : Chained('id') : PathPart('retrieve') : Args(0) {
    my ( $self, $c ) = @_;

    $c->stash( template => 'page/retrieve.html' );
}

=head1 AUTHOR

Alan Haggai Alavi

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
