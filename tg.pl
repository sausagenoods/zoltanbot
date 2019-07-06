use strict;
use warnings;

use LWP::UserAgent qw( );
use LWP::Simple;

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
        if ($update->{message}->{chat}->{id} == $chat) {
            send_message($token, $chat, $update->{message}->{text});
            $offset = $update->{update_id}+1;
        }
    }
}

1;
