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
        
        if ($message->{chat}->{id} == $chat) {
            if ($message->{entities}[0]->{type} eq "bot_command") {
                command_handlers($token, $chat, $message);
            }
            $offset = $update->{update_id}+1;
        }
    }
}

sub command_handlers
{
    my ($token, $chat, $msg) = @_;
    my ($cmd, $args) = split(' ', $msg->{text}, 2);
    my $id = $msg->{message_id};
    
    if ($cmd =~ /\/msgcount/) {
        send_message($token, $chat, $id, $id);
    }
    elsif ($cmd =~ /\/8ball/) {
        ask_ball($token, $chat, $args, $id);
    }
    elsif ($cmd =~ /\/(ud|urbandict|dictionary)/) {
        urban_dictionary($token, $chat, $args, $id);
    }
    else {
        send_message($token, $chat, "Unknown command.", $id);
    }
}

1;
