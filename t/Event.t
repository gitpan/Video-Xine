use strict;
use warnings;

use FindBin '$Bin';
use Test::More tests => 1;
use Video::Xine;
use Video::Xine::Stream ':status_constants';
use Video::Xine::Event ':type_constants';

our $DEBUG = 1;

SKIP: {

  my $xine = Video::Xine->new(config_file => "$Bin/test_config");

  my ($driver, $display_str, $display, $window);

  if (defined($ENV{'VIDEO_XINE_SHOW'}) && $ENV{'VIDEO_XINE_SHOW'}) {
    eval { require X11::FullScreen; };

    if ($@) {
      skip("Couldn't load X11::FullScreen: $@", 1);
    }

    my $display_str = defined $ENV{'DISPLAY'} ? $ENV{'DISPLAY'} : ':0.0';


    $display = X11::FullScreen::Display->new($display_str)
      or skip("X11::FullScreen::Display does not initialize", 1);

    $window = $display->createWindow();
    $display->sync();
    my $x11_visual = 
      Video::Xine::Util::make_x11_visual($display,
					 $display->getDefaultScreen(),
					 $window,
					 $display->getWidth(),
					 $display->getHeight(),
					 $display->getPixelAspect()
					);
    $driver = Video::Xine::Driver::Video->new($xine,"auto", 1, $x11_visual, $display)
	or skip("Unable to load video driver", 1);
  }
  else {
    $driver = Video::Xine::Driver::Video->new($xine, 'none')
	or skip("Unable to load 'none' video driver", 1);
  }

  my $null_audio = Video::Xine::Driver::Audio->new($xine, 'none')
    or skip q{Could not load audio driver 'none'}, 1;

  my $stream = $xine->stream_new($null_audio, $driver);

  my $queue = Video::Xine::Event::Queue->new($stream);
  
  $stream->open("$Bin/time_015.avi")
    or die "Couldn't open '$Bin/time_015.avi'";
  $stream->play( 0, int(.7 * 65535) );

  PLAY: for (;;) {
    while ( my $event = $queue->get_event() ) {
      print "Event: ", $event->get_type(), "\n"
	if $DEBUG;
      $event->get_type() == XINE_EVENT_UI_PLAYBACK_FINISHED and last PLAY;
    }
    sleep(1);
  }

  ok(1);

}


