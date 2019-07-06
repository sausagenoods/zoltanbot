use strict;
use warnings;

use LWP::UserAgent;

my $base_url = "https://api.telegram.org/";

sub send_message
{
    my ($token, $chat, $message) = @_;
    my $method = "sendMessage";
    my $url = $base_url."bot".$token."/".$method;
    my $ua = LWP::UserAgent->new();
    my $response = $ua->post($url, [chat_id => $chat, text => $message]);
}

1;
