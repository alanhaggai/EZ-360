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

    $c->forward( '/check_user_roles', [qw/user/] );

    if ( lc $c->request->method() eq 'post' ) {
        my $title           = $c->request->body_params->{'title'};
        my $articles_string = $c->request->body_params->{'articles-string'};
        my $parent          = $c->request->body_params->{'parent'};

        my @articles = split /\s/, $articles_string;

        my $status_message;
        if ($title) {
            my $page;
            eval {
                $page = $c->model('DB::Page')->create( { title => $title } );
                for (@articles) {
                    $page->create_related( 'articles', { article_id => $_ } );
                }
                if ($parent) {
                    $c->model('DB::PageRelation')
                      ->create( { page_id => $parent, child => $page->id() } );
                }
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

    $c->forward( '/check_user_roles', [qw/user/] );

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

sub delete : Chained('id') : PathPart('delete') : Args(0) {
    my ( $self, $c ) = @_;

    $c->forward( '/check_user_roles', [qw/user/] );

    if ( lc $c->request->method() eq 'post' ) {
        eval {
            my $page = $c->stash->{page};
            $page->delete_related('articles');
            $page->delete_related('children');
            $page->delete_related('parent');
            $page->delete();
        };

        if ($@) {
            $c->response->redirect(
                $c->uri_for(
                    '/status',
                    { error_message => 'Error occurred while deleting page.' }
                )
            );
        }
        else {
            $c->response->redirect(
                $c->uri_for(
                    '/page/list',
                    { success_message => 'Page deleted successfully.' }
                )
            );
        }
    }
    else {
        $c->stash( template => 'page/delete.html' );
    }
}

sub retrieve : Chained('id') : PathPart('retrieve') : Args(0) {
    my ( $self, $c ) = @_;

    $c->forward( '/check_user_roles', [qw/user/] );

    $c->stash( template => 'page/retrieve.html' );
}

sub update : Chained('id') : PathPart('update') : Args(0) {
    my ( $self, $c ) = @_;

    $c->forward( '/check_user_roles', [qw/user/] );

    if ( lc $c->request->method() eq 'post' ) {
        my $title           = $c->request->body_params->{'title'};
        my $articles_string = $c->request->body_params->{'articles-string'};
        my $parent          = $c->request->body_params->{'parent'};

        my @articles = split /\s/, $articles_string;

        my $status_message;
        if ($title) {
            my $page = $c->stash->{page};
            eval {
                $page->title($title);

                if (@articles) {
                    $page->delete_related( 'articles',
                        { page_id => $page->id() } );
                    for (@articles) {
                        $page->create_related( 'articles',
                            { article_id => $_ } );
                    }
                }
                if ($parent) {
                    {
                        local $@;
                        eval { $page->parent()->delete() };
                        undef $@;
                    }
                    $c->model('DB::PageRelation')
                      ->update_or_create(
                        { page_id => $parent, child => $page->id() } );
                }
                $page->update();
            };

            if ($@) {
                $status_message = 'Error while updating page.' . $@;
            }
            else {
                $c->response->redirect(
                    $c->uri_for(
                        '/page/' . $page->id() . '/retrieve',
                        { success_message => 'Page updated successfully.' }
                    )
                );

                return;
            }
        }

        $status_message ||= 'Title or articles not provided';
        $c->response->redirect(
            $c->uri_for( '/status', { notice_message => $status_message } ) );
    }

    my @articles = $c->model('DB::Article')->all();
    my @articles_not_in_page;
    for my $article (@articles) {
        my $flag = 0;
        for ( $c->stash->{page}->articles() ) {
            if ( $_->article_id() == $article->id() ) {
                $flag = 1;
                last;
            }
        }
        push @articles_not_in_page, $article if $flag == 0;
    }

    $c->stash(
        articles             => [@articles],
        articles_not_in_page => [@articles_not_in_page],
        pages                => [ $c->model('DB::Page')->all() ],
        template             => 'page/update.html',
    );
}

=head1 AUTHOR

Alan Haggai Alavi

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
