package Gallry;
use Mojo::Base 'Mojolicious';

use JSON;

# This method will run once at server start
sub startup {
    my $self = shift;

    my $config = $self->plugin('Config');

    $self->secrets($config->{secret});

    $self->helper(auth => sub {
        my $cont = shift;
        my $url = $cont->req->url->to_abs->path;
        $url =~ s/\/\d+$//;
        my $local_config_file =
            "public" . $url . "/.config.json";
        my $galpwhash;
        {
            local $/;
            open( my $fh, '<', $local_config_file );
            my $json_text   = <$fh>;
            my $galconf = decode_json( $json_text );
            $galpwhash = $galconf->{pwhash} || '';
        }
        # No PW set!
        return 1 if not $galpwhash;
        # No PW cookie! Ask for PW
        return undef if not $cont->session('password');
        # PW matches
        return 1 if $cont->session('password') eq $galpwhash;
        # Default (No match)
        return undef;
    });

    # Router
    my $r = $self->routes;

    $r->get('/')->to('gallry#index')->name('index');
    $r->get('/about')->to('gallry#about');
    $r->any('/login')->to('gallry#login');
    my $p = $r->under(sub {
        my $self = shift;
        return 1 if $self->auth;
        $self->session->{target} = $self->req->url->to_abs->path;
        $self->redirect_to('/login');
        return;
    });
    $p->get('/galleries/:gallery/:start')->to('gallry#show', start => 0);
}

1;
