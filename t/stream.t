use strict;
use warnings;

use FindBin '$Bin';
use Test::More tests => 4;

use Video::Xine;
use Video::Xine::Stream qw/:status_constants :info_constants/;
use Video::Xine::Driver::Audio;
use Video::Xine::Driver::Video;

my $xine = Video::Xine->new()
  or die "Couldn't open Xine";

my $ao = Video::Xine::Driver::Audio->new($xine, 'none')
  or die "Couldn't open audio driver";

# Get our stream
my $stream = $xine->stream_new($ao);

$stream->open("$Bin/time_015.avi");

is($stream->get_info(XINE_STREAM_INFO_BITRATE), 0);
is($stream->get_info(XINE_STREAM_INFO_FRAME_DURATION), 3003);
is($stream->get_info(XINE_STREAM_INFO_VIDEO_WIDTH), 704);
is($stream->get_info(XINE_STREAM_INFO_VIDEO_HEIGHT), 480);
