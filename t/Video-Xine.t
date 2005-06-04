# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl Video-Xine.t'

#########################

use strict;
use FindBin '$Bin';
use Test::More tests => 10;
BEGIN { use_ok('Video::Xine') };

#########################


my $xine = Video::Xine->new(config_file => "$Bin/test_config");
ok(1);

TEST1: {
  my $stream  = $xine->stream_new();
  is($stream->get_status(), XINE_STATUS_IDLE);
  $stream->open("$Bin/time_015.avi")
    or die "Couldn't open '$Bin/time_015.avi'";
  my ($pos_pct, $pos_time, $length_time) = $stream->get_pos_length();
  is($pos_pct, 0);
  is($pos_time, 0);
  is($length_time, 14981);
  $stream->play();
  is($stream->get_status(), XINE_STATUS_PLAY);
  $stream->stop();
  is($stream->get_status(), XINE_STATUS_STOP);
  $stream->close();
  is($stream->get_status(), XINE_STATUS_IDLE);
}

SKIP: {
  skip "I need to find a short, open-source test file", 1;
  my $stream = $xine->stream_new();
  $stream->open("/dev/null")
    or die "Couldn't open '/dev/null'";
  $stream->play()
	or die "Couldn't play '/dev/null'";
  while ($stream->get_status() == XINE_STATUS_PLAY) {
    sleep 1;
  }
  $stream->close();
  ok(1);
}
