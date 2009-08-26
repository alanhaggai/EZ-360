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

=head2 index

=cut

sub index : Path : Args(0) {
    my ( $self, $c ) = @_;
    #$c->response->body('Matched EZ::360::Controller::Article in Article.');
    $c->detach('/default');
}

sub create : Local {
    my ( $self, $c ) = @_;
}

sub id : Chained('/') : PathPart('article') : CaptureArgs(1) {
    my ( $self, $c, $id ) = @_;
}

sub delete : Chained('id') : PathPart('delete') : Args(0) {
    my ( $self, $c ) = @_;
}

sub delete_do : Chained('id') : PathPart('delete/do') : Args(0) {
    my ( $self, $c ) = @_;
}

sub update : Chained('id') : PathPart('update') : Args(0) {
    my ( $self, $c ) = @_;
}

sub update_do : Chained('id') : PathPart('update/do') : Args(0) {
    my ( $self, $c ) = @_;
}

=head1 AUTHOR

Alan Haggai Alavi

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;