#!/usr/bin/perl
#                          _
# Author: Winterlinn     ('v')
# Kernal Community      //-=-\\
# 2017 - 2019           (\_=_/)
#                        ^^ ^^  apx

use strict;
use warnings;
use JSON;

require "./tg.pl";

my $json_text;
{
    local $/;
    open my $fh, "<", "config.json" or die "Couldn't open config.json";
    $json_text = <$fh>;
    close $fh;
}

my $bot = decode_json($json_text);
my $bot_token = $bot->{bot_token};
my $chat_id = $bot->{chat_id};

while (1) {
    get_updates($bot_token, $chat_id);
}
