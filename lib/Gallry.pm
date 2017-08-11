package Gallry;
use Mojo::Base 'Mojolicious';

use JSON;

# This method will run once at server start
sub startup {
    my $self = shift;

    my $config = $self->plugin('Config');

    $self->secrets($config->{secret});
    $self->plugin('RenderFile');

    $self->helper(auth => sub {
        my $cont = shift;
        my $url = $cont->req->url->to_abs->path;
        my $target = $cont->session('target');
        # Already logged in for the current gallery
        return 1 if $cont->session
                 and $cont->session('logged_in') == 1
                 and $url =~ m/$target/;

        my $local_config_file = $url;
        $local_config_file =~ s/^\///;
        $local_config_file =~ s/galleries\/([a-zA-Z0-9]+).*$/galleries\/$1/;
        $local_config_file .= '/.config.json';
        my $galpwhash;
        {
            local $/;
            open( my $fh, '<', $local_config_file );
            my $json_text   = <$fh>;
            my $galconf = decode_json( $json_text );
            $galpwhash = $galconf->{pwhash} || '';
        }
        # No PW set in config for this gallery!
        return 1 unless $galpwhash;

        return unless $url =~ m/$target/;

        # Not logged in
        # No password supplied by user
        return unless $cont->session('password');
        # PW matches, also set logged_in to a true value
        return 1 if $cont->session('password') eq $galpwhash and $cont->session('logged_in' => 1);
        # Default (No match)
        return;
    });

    # Router
    my $r = $self->routes;

    $r->get('/')->to('gallry#index')->name('index');
    $r->get('/about')->to('gallry#about');
    $r->any('/login')->to('gallry#login');
    my $p = $r->under(sub {
        my $self = shift;
        return 1 if $self->auth;
        $self->session(logged_in => 0);
        $self->session->{target} = $self->req->url->to_abs->path;
        $self->redirect_to('/login');
        return;
    });
    $p->get('/galleries/:gallery/images.zip')->to('gallry#zip');
    $p->get('/galleries/:gallery/:start')->to('gallry#show', start => 0);
    $p->get('/galleries/:gallery/images/#filename')->to('gallry#bigimage');
    $p->get('/galleries/:gallery/images/thumbs/#filename')->to('gallry#thumbnail');
    $p->get('/galleries/:gallery/videos/#filename')->to('gallry#videos');
}

1;
