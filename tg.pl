use strict;
use warnings;

use LWP::UserAgent qw( );
use LWP::Simple;

require "./command.pl";

my $base_url = "https://api.telegram.org/";

sub send_message
{
    my ($token, $chat, $message) = @_;
    my $method = "sendMessage";
    my $url = "${base_url}bot${token}/${method}";
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
            if ($message->{text} =~ /^\//) {
                command_handlers($token, $chat, $message);
            }
            $offset = $update->{update_id}+1;
        }
    }
}

sub command_handlers
{
    my ($token, $chat, $msg) = @_;
    
    if ($msg->{text} =~ /\/msgcount/) {
        send_message($token, $chat, $msg->{message_id});
    }
    elsif ($msg->{text} =~ /\/8ball/) {
        ask_ball($token, $chat);
    }
}

1;
