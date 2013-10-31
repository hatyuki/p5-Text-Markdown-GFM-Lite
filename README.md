# NAME

Text::Markdown::GFM::Lite - Convert Markdown to HTML using GitHub Flavored Markdown (GFM)

# SYNOPSIS

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

# DESCRIPTION

Text::Markdown::GFM::Lite is simple wrapper library for converting raw text to HTML using GitHub Flavored Markdown.
It uses the GitHub API.

# METHODS

## __Text::Markdown::GFM::Lite->new(%options)__

    my $tmgl = Text::Markdown::GFM::Lite->new(
        access_token => 'Your GitHub AccessToken',
        user_agent   => Furl::HTTP->new, # Custom agent is required to implement 'post' method corresponding to the same named methods of Furl::HTTP.
        api_url      => 'https://api.github.com/markdown/raw', # It's default,
    );

- `access_token`

    Specify an access token of the github.com if you want to call GFM API with it.

- `user_agent`

    The Furl::HTTP compatible class used internally by Text::Markdown::GFM::Lite. It defaults to "Furl::HTTP".

- `api_url`

## __$tmgl->render\_string($string) : String__

Rendering GitHub Flavored Markdown using Markdown Rendering API.

## __$tmgl->render($filename) : String__

Rendering GFM from $filename.

## __$tmgl->api\_ratelimit : Integer__

The maximum number of requests that the consumer is permitted to make per hour.

## __$tmgl->api\_remaining : Integer__

The number of requests remaining in the current rate limit window.

## __$tmgl->api\_ratereset : Epoch__

The time at which the current rate limit window resets in UTC epoch seconds.

# SEE ALSO

GitHub Flavored Markdown: [https://help.github.com/articles/github-flavored-markdown](https://help.github.com/articles/github-flavored-markdown)

Markdown Rendering API: [http://developer.github.com/v3/markdown/](http://developer.github.com/v3/markdown/)

# LICENSE

Copyright (C) hatyuki.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

# AUTHOR

hatyuki <hatyuki29@gmail.com>
