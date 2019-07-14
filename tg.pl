use strict;
use warnings;

use LWP::UserAgent qw( );
use LWP::Simple;

require "./command.pl";

my $base_url = "https://api.telegram.org/";

sub send_message
{
    my ($token, $chat, $message, $msg_id) = @_;
    my $method = "sendMessage";
    my $url = "${base_url}bot${token}/${method}?reply_to_message_id=${msg_id}";
    my $ua = LWP::UserAgent->new();
    my $response = $ua->post($url, [chat_id => $chat, text => $message]);
}

my $offset = 0;

sub get_updates
{
    my ($token, $chat) = @_;
    my $method = "getUpdates";
    my $url = "${base_url}bot${token}/${method}?offset=${offset}";
    my $updates = get($url); 
    my $json = decode_json($updates);
    
    for my $update (@{$json->{result}}) {
        
        my $message = $update->{message};
        my $chat_id = $message->{chat}->{id};
    
        if (defined($chat_id) && $chat_id == $chat) {
            print $message->{text};
            handlers($token, $chat, $message);                    
        }
        $offset = $update->{update_id}+1;
    }
}

our $help_str;

sub handlers
{
    my ($token, $chat, $msg) = @_;

    my $id = $msg->{message_id};
    my $type = $msg->{entities}[0]->{type};
    my $text = $msg->{text};

    if (defined($type) && $type eq "bot_command") {
        
        my ($cmd, $args) = split(' ', $text, 2);
        $cmd =~ s/@.*//;

        if ($cmd =~ /^\/msgcount$/) {
            send_message($token, $chat, $id, $id);
        }
        elsif ($cmd =~ /^\/8ball$/) {
            ask_ball($token, $chat, $args, $id);
        }
        elsif ($cmd =~ /^\/(ud|urbandict|dictionary)$/) {
            urban_dictionary($token, $chat, $args, $id);
        }
        elsif ($cmd =~ /^\/owofy$/) {
            owofy($token, $chat, $args, $id);
        }
        elsif ($cmd =~ /^\/help$/) {
            send_message($token, $chat, $help_str, $id);
        }
        else {
            send_message($token, $chat, "Unknown command.", $id);
        }
    } else {
        if ($text =~ /\bkms\b/) {
            suicide_prevention($token, $chat, $msg->{from}->{username}, $id);
        }
    }
}

1;
