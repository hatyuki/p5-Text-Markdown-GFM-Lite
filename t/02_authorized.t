use strict;
use warnings;
use Test::More 0.98;
use Text::Markdown::GFM::Lite;
plan skip_all => '$ENV{GITHUB_ACCESS_TOKEN} is required' unless $ENV{GITHUB_ACCESS_TOKEN};

subtest render_string  => sub {
    my $tmgl = Text::Markdown::GFM::Lite->new(access_token => $ENV{GITHUB_ACCESS_TOKEN});
    my $mkd  = $tmgl->render_string('# Foo');

    like $mkd, qr/^<h1>/;
    like $tmgl->api_ratelimit, qr/^\d+$/;
    like $tmgl->api_remaining, qr/^\d+$/;
    like $tmgl->api_ratereset, qr/^\d+$/;
};

done_testing;
