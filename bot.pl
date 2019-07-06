#!/usr/bin/perl

use strict;
use warnings;
use LWP::UserAgent;

require "./util.pl";
require "./tg.pl";

my $bot = load_config("config.json");
my $bot_token = $bot->{bot_token};
my $chat_id = $bot->{chat_id};

send_message($bot_token, $chat_id, "t.me/kernals");
