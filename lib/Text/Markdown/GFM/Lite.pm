package Text::Markdown::GFM::Lite;
use 5.008005;
use strict;
use warnings;
use Carp ( );
use Furl::HTTP;
use Class::Accessor::Lite (
    new => 0,
    ro  => [qw/ api_url user_agent /],
    rw  => [qw/ access_token api_status /],
);

our $VERSION = "0.01";

sub new
{
    my $class = shift;
    my %args  = scalar @_ == 1 && $_[0] eq 'HASH' ? %{ @_ } : @_;

    return bless +{
        access_token  => undef,
        api_status    => +{ },
        api_url       => 'https://api.github.com/markdown/raw',
        user_agent    => Furl::HTTP->new(timeout => 10),
        %args,
    }, $class;
}

sub render
{
    my ($self, $file) = @_;
    open my $fh, '<', $file or Carp::croak $!;
    return $self->render_string( do { local $/; <$fh> } );
}

sub render_string
{
    my ($self, $string) = @_;
    my ($v, $status, $m, $headers, $markdown) = $self->user_agent->post(
        $self->api_url, $self->build_request_header, $string,
    );

    Carp::croak($markdown) if $status != 200;

    $self->set_api_status_from_header($headers);

    return $markdown;
}

sub build_request_header
{
    my $self = shift;
    my $header = [ 'Content-Type' => 'text/x-markdown' ];

    if ($self->access_token) {
        push @$header, (Authorization => 'token ' . $self->access_token);
    }

    return $header;
}

sub set_api_status_from_header
{
    my ($self, $headers) = @_;
    my %h = @$headers;

    $self->api_status( +{
            ratelimit => $h{'x-ratelimit-limit'},
            remaining => $h{'x-ratelimit-remaining'},
            ratereset => $h{'x-ratelimit-reset'},
        },
    );
}

sub api_ratelimit { $_[0]->api_status->{ratelimit} }
sub api_remaining { $_[0]->api_status->{remaining} }
sub api_ratereset { $_[0]->api_status->{ratereset} }

1;

__END__

=encoding utf-8

=head1 NAME

Text::Markdown::GFM::Lite - Convert Markdown to HTML using GitHub Flavored Markdown (GFM)

=head1 SYNOPSIS

    use Text::Markdown::GFM::Lite;
    use Try::Tiny;
    my $tmgl = Text::Markdown::GFM::Lite->new;
    my $html;
    try {
        $html = $tm->render_string('write your markdown here');
        # or ...
        $html = $tm->render($path_to_markdown_file);
    } catch {
        die $_;
    };
    $tm->api_remaining; ## remaining count

=head1 DESCRIPTION

Text::Markdown::GFM::Lite is simple wrapper library for converting raw text to HTML using GitHub Flavored Markdown.
It uses the GitHub API.

=head1 METHODS

=head2 B<< Text::Markdown::GFM::Lite->new(%options) >>

    my $tmgl = Text::Markdown::GFM::Lite->new(
        access_token => 'Your GitHub AccessToken',
        user_agent   => Furl::HTTP->new, # Custom agent is required to implement 'post' method corresponding to the same named methods of Furl::HTTP.
        api_url      => 'https://api.github.com/markdown/raw', # It's default,
    );

=over

=item C<< access_token >>

Specify an access token of the github.com if you want to call GFM API with it.

=item C<< user_agent >>

The Furl::HTTP compatible class used internally by Text::Markdown::GFM::Lite. It defaults to "Furl::HTTP".

=item C<< api_url >>

=back

=head2 B<< $tmgl->render_string($string) : String >>

Rendering GitHub Flavored Markdown using Markdown Rendering API.

=head2 B<< $tmgl->render($filename) : String >>

Rendering GFM from $filename.

=head2 B<< $tmgl->api_ratelimit : Integer >>

The maximum number of requests that the consumer is permitted to make per hour.

=head2 B<< $tmgl->api_remaining : Integer >>

The number of requests remaining in the current rate limit window.

=head2 B<< $tmgl->api_ratereset : Epoch >>

The time at which the current rate limit window resets in UTC epoch seconds.

=head1 SEE ALSO

GitHub Flavored Markdown: L<https://help.github.com/articles/github-flavored-markdown>

Markdown Rendering API: L<http://developer.github.com/v3/markdown/>

=head1 LICENSE

Copyright (C) hatyuki.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

hatyuki E<lt>hatyuki29@gmail.comE<gt>

=cut
