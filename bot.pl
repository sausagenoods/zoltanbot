#!/usr/bin/perl
#                          _
# Author: Siren          ('v')
# Kernal Community      //-=-\\
# 2017 - 2021           (\_=_/)
#                        ^^ ^^  apx

use strict;
use warnings;
# use lib '/home/void/perl5/lib/perl5';
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
my @modules = $bot->{modules};
my $base_url = "https://api.telegram.org/";

my $synth = "synth" ~~ @modules ? 1 : 0;
our $markov = "markov" ~~ @modules ? 1 : 0;
our $shh = $markov ? 1 : 0;

my $help_str =
"-Commands available-
/msgcount
/8ball
/ud
/owofy
/corpus
/exec
/slaep
/bleed
/synth
/shh
/rules";

sub send_message
{
    my ($message, $msg_id) = @_;
    my $method = "sendMessage";
    my $url = "${base_url}bot${bot_token}/${method}?reply_to_message_id=${msg_id}";
    my $ua = LWP::UserAgent->new();
    my $response = $ua->post($url, [chat_id => $chat_id, text => $message]);
}

sub send_file
{
    my ($file, $msg_id) = @_;
    my $method = "sendDocument";
    my $url = "${base_url}bot${bot_token}/${method}?reply_to_message_id=${msg_id}";
    my $ua = LWP::UserAgent->new();
    my $response = $ua->post($url, Content_Type => 'form-data', Content => ["chat_id" => $chat_id, "document" => ["$file"]]);
}

sub send_typing
{
    my $method = "sendChatAction";
    my $url = "${base_url}bot${bot_token}/${method}?action=typing&chat_id=${chat_id}";
    my $ua = LWP::UserAgent->new();
    my $action = $ua->post($url);
}

my $offset = 0;

sub get_updates
{
    my $method = "getUpdates";
    my $url = "${base_url}bot${bot_token}/${method}?offset=${offset}";
    my $updates = get($url);
    if ($updates) {
        my $json = decode_json($updates);

        if (length($json) > 0) {
            for my $update (@{$json->{result}}) {

                my $message = $update->{message};
                my $chat = $message->{chat}->{id};

                if (defined($chat) && $chat_id == $chat) {
                    handlers($message);
                }
                $offset = $update->{update_id}+1;
            }
        }
    }
}

sub handlers
{
    my ($msg) = @_;

    my $id = $msg->{message_id};
    my $type = $msg->{entities}[0]->{type};
    my $uname = $msg->{from}->{username};
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
        elsif ($cmd =~ /^\/corpus$/) {
            to_corpus($args, $id);
        }
        elsif ($cmd =~ /^\/help$/) {
            send_message($help_str, $id);
        }
        elsif ($cmd =~ /^\/exec$/) {
            execute($msg->{from}->{id}, $args, $id);
        }
        elsif ($cmd =~ /^\/slaep$/) {
            slaep($uname, $id);
        }
        elsif ($cmd =~ /^\/bleed/) {
            bleed($id);
        }
        elsif ($cmd =~ /^\/rules/) {
	    rules($id);
        }
	elsif ($cmd =~ /^\/shh$/ && $markov) {
	        $shh ^= 1;
        }
	elsif ($cmd =~ /^\/synth/ && $synth) {
            synth($args, $id);
	}
        #else {
        #    send_message("Unknown command.", $id);
        #}
    } else {
        if (defined($text) && $text =~ /\bkms\b/) {
            suicide_prevention($uname, $id);
        }
	elsif (defined($text) && $markov) {
	    markov($text, $id);
    	}
    }
}

get("${base_url}bot${bot_token}/getUpdates?offset=-1");

while (1) {
    get_updates($bot_token, $chat_id);
}
