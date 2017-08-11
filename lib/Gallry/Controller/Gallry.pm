package Gallry::Controller::Gallry;
use Mojo::Base 'Mojolicious::Controller';

use JSON;
use Digest::SHA qw(sha512_hex);

sub index {
    my $self = shift;
    my $stash = $self->stash;
    my $config = $stash->{config};

    my @galleries;
    @galleries =  glob 'galleries/*';
    $self->stash( galleries => \@galleries );
}

sub login {
    my $self = shift;
    my $stash = $self->stash;
    my $config = $stash->{config};

    my $password = $self->param('password') || '';
    if( $password ) {
        $self->session(password => sha512_hex $password);
        $self->redirect_to($self->session->{target} || '/');
    }
}

sub bigimage {
    my $self = shift;
    my $stash = $self->stash;
    my $gallery = $self->param('gallery');
    my $filename = $self->param('filename');
    my $ext = $filename;
    $ext =~ s/^.*\.//;

    $self->render_file(filepath            => "galleries/$gallery/images/$filename",
                       format              => $ext,
                       content_disposition => 'inline');
}

sub thumbnail {
    my $self = shift;
    my $stash = $self->stash;
    my $gallery = $self->param('gallery');
    my $filename = $self->param('filename');
    my $ext = $filename;
    $ext =~ s/^.*\.//;

    $self->render_file(filepath            => "galleries/$gallery/images/thumbs/$filename",
                       format              => $ext,
                       content_disposition => 'inline');
}

sub zip {
    my $self = shift;
    my $stash = $self->stash;
    my $gallery = $self->param('gallery');

    $self->render_file('filepath' => "galleries/$gallery/images.zip");
}

sub show {
    my $self = shift;
    my $stash = $self->stash;
    my $config = $stash->{config};
    my $gallery = $self->param('gallery');
    my $start = $self->param('start');

    my @pics = map { s/^/\//r }
               grep { /\.[Jj][Pp][Ee][Gg]$|\.[Jj][Pp][Gg]$|\.[Pp][Nn][Gg]$|\.[Gg][Ii][Ff]$/ }
               glob "galleries/$gallery/images/thumbs/*";
    my @vids = map { s/^\//r }
               grep { /\.mp4$/ }
               glob "galleries/$gallery/videos/*";

    my $end = $start + 14;
    $end = $#pics if $end > $#pics;

    my $prev = $start - 15;
    $prev = -1 if $prev < 0;

    my $next = $end + 1;
    $next = -1 if $next > $#pics;

    my @send = @pics[$start .. $end];
    my @before = @pics[0 .. $start-1];
    my @after = @pics[$end+1 .. $#pics];

    my $galconf;
    {
        local $/;
        open( my $fh, '<', "galleries/$gallery/.config.json" );
        my $json_text   = <$fh>;
        $galconf = decode_json( $json_text );
    }

    $self->stash( title  => $galconf->{title} );
    $self->stash( date   => $galconf->{date} );
    $self->stash( author => $galconf->{author} );
    $self->stash( vids   => \@vids );
    $self->stash( images => \@send );
    $self->stash( before => \@before );
    $self->stash( after  => \@after );
    $self->stash( prev   => $prev );
    $self->stash( next   => $next );
}

1;
