use strict;
use warnings;

require "./tg.pl";

sub ask_ball
{
    my ($token, $chat, $args, $id) = @_;
   
    my @answers = (
        "It is certain.",
        "It is decidedly so.",
        "Without a doubt.",
        "Yes - definitely.",
        "You may rely on it.",
        "As I see it, yes.",
        "Most likely.",
        "Outlook good.",
        "Yes.",
        "Signs point to yes.",
        "Reply hazy, try again.",
        "Ask again later.",
        "Better not tell you now.",
        "Cannot predict now.",
        "Concentrate and ask again.",
        "Don't count on it.",
        "My reply is no.",
        "My sources say no.",
        "Outlook not so good.",
        "Very doubtful."
    );
   
    if (!defined $args) {
        send_message($token, $chat, "Ask me something.", $id);
    }
    elsif ($args =~ /(what|who|when|why|whose|when|how)/) {
        send_message($token, $chat, "Ask me a yes-no question instead.", $id);
    }
    else {
    send_message($token, $chat, $answers[rand @answers], $id); 
    }
} 

sub urban_dictionary
{
    my ($token, $chat, $args, $id) = @_;

    if (!defined $args) {
        send_message($token, $chat, "Nothing to look up for.", $id);
    }

    my $url = "http://api.urbandictionary.com/v0/define?term=${args}";
    my $content = get($url);
    my $json = decode_json($content);

    if ($json->{list}[0]) {
        my $definition = $json->{list}[0]->{definition};
        send_message($token, $chat, $definition, $id);
    }
    else {
        send_message($token, $chat, "Definition not found.", $id);
    }
}

1;
