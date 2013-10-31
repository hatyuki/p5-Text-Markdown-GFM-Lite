use strict;
use warnings;
use File::Temp ( );
use Test::More 0.98;
use Text::Markdown::GFM::Lite;

subtest initialize => sub {
    my $tmgl = Text::Markdown::GFM::Lite->new;
    is $tmgl->api_url, 'https://api.github.com/markdown/raw';
    ok not defined $tmgl->access_token;
    ok not defined $tmgl->api_ratelimit;
    ok not defined $tmgl->api_remaining;
    ok not defined $tmgl->api_ratereset;
    isa_ok $tmgl->user_agent, 'Furl::HTTP';
};

subtest render_string  => sub {
    my $tmgl = Text::Markdown::GFM::Lite->new;
    my $mkd  = $tmgl->render_string('# Foo');

    like $mkd, qr/^<h1>/;
    like $tmgl->api_ratelimit, qr/^\d+$/;
    like $tmgl->api_remaining, qr/^\d+$/;
    like $tmgl->api_ratereset, qr/^\d+$/;
};

subtest render_file => sub {
    my $fh = File::Temp->new(UNLINK => 1);
    $fh->print('- Bar');
    $fh->close;

    my $tmgl = Text::Markdown::GFM::Lite->new;
    my $mkd  = $tmgl->render($fh->filename);
    like $mkd, qr/^<ul>/;
    like $tmgl->api_ratelimit, qr/^\d+$/;
    like $tmgl->api_remaining, qr/^\d+$/;
    like $tmgl->api_ratereset, qr/^\d+$/;
};

subtest raise_error => sub {
    subtest invalid_user_agent => sub {
        my $tmgl = Text::Markdown::GFM::Lite->new(user_agent => undef);
        eval { $tmgl->render_string('# Invalid User Agent') };
        ok $@;
    };

    subtest invalid_api_url => sub {
        my $tmgl = Text::Markdown::GFM::Lite->new(api_url => undef);
        eval { $tmgl->render_string('# Invalid API URL') };
        ok $@;
    };

    subtest invalid_access_token => sub {
        my $tmgl = Text::Markdown::GFM::Lite->new(access_token => 'invalid_access_token');
        eval { $tmgl->render_string('# Invalid Access Token') };
        ok $@;
    };
};

done_testing;
