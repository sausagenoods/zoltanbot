#!/usr/bin/perl
#                          _
# Author: Winterlinn     ('v')
# Kernal Community      //-=-\\
# 2017 - 2019           (\_=_/)
#                        ^^ ^^  apx

use strict;
use warnings;
use JSON;
use LWP::UserAgent qw( );
use LWP::Simple;

require "./cmd.pl";

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
our @sudo_users = $bot->{sudo_users};
my $base_url = "https://api.telegram.org/";

my $help_str = 
"-Commands available-
/msgcount
/8ball
/ud
/owofy
/exec";
                                           
sub send_message
{
    my ($message, $msg_id) = @_;
    my $method = "sendMessage";
    my $url = "${base_url}bot${bot_token}/${method}?reply_to_message_id=${msg_id}";
    my $ua = LWP::UserAgent->new();
    my $response = $ua->post($url, [chat_id => $chat_id, text => $message]);
}

my $offset = 0;

sub get_updates
{
    my $method = "getUpdates";
    my $url = "${base_url}bot${bot_token}/${method}?offset=${offset}";
    my $updates = get($url);
    my $json = decode_json($updates);

    for my $update (@{$json->{result}}) {

        my $message = $update->{message};
        my $chat = $message->{chat}->{id};

        if (defined($chat) && $chat_id == $chat) {
            handlers($message);
        }
        $offset = $update->{update_id}+1;
    }
}

sub handlers
{
    my ($msg) = @_;

    my $id = $msg->{message_id};
    my $type = $msg->{entities}[0]->{type};
    my $text = $msg->{text};

    if (defined($type) && $type eq "bot_command") {

        my ($cmd, $args) = split(' ', $text, 2);
        $cmd =~ s/@.*//;

        if ($cmd =~ /^\/msgcount$/) {
            send_message($id, $id);
        }
        elsif ($cmd =~ /^\/8ball$/) {
            ask_ball($args, $id);
        }
        elsif ($cmd =~ /^\/(ud|urbandict|dictionary)$/) {
            urban_dictionary($args, $id);
        }
        elsif ($cmd =~ /^\/owofy$/) {
            owofy($args, $id);
        }
        elsif ($cmd =~ /^\/help$/) {
            send_message($help_str, $id);
        }
        elsif ($cmd =~ /^\/exec$/) {
            execute($msg->{from}->{id}, $args, $id);
        }
        #else {
        #    send_message("Unknown command.", $id);
        #}
    } else {
        if ($text =~ /\bkms\b/) {
            suicide_prevention($msg->{from}->{username}, $id);
        }
    }
}

while (1) {
    get_updates($bot_token, $chat_id);
}
