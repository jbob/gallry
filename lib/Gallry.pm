package Gallry;
use Mojo::Base 'Mojolicious';

# This method will run once at server start
sub startup {
  my $self = shift;

  my $config = $self->plugin('Config');

  $self->secrets($config->{secret});

  $self->helper(auth => sub {
      my $self = shift;
      return undef if not $self->session('password');
      return 1 if $self->session('password') eq $config->{password};
  });

  # Router
  my $r = $self->routes;

  $r->get('/')->to('gallry#index')->name('index');
  $r->get('/about')->to('gallry#about');
  $r->any('/login')->to('gallry#login');
  my $p = $r->under(sub {
      my $self = shift;
      return 1 if $self->auth;
      $self->redirect_to('/login');
      return;
  });
  $p->get('/galleries/:gallery/:start')->to('gallry#show', start => 0);

}

1;
