use strict;
use warnings;

require "./tg.pl";

our $help_str = 
"-Commands available-
/msgcount
/8ball
/ud
/owofy";

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

sub execute
{
    my ($token, $chat, $args, $id) = @_;

    if (!defined $args) {
        send_message($token, $chat, "Nothing to execute.", $id);
    }
    else {
        my $out = `${args}`;
        send_message($token, $chat, $out, $id);
    }
}

sub owofy
{
    my ($token, $chat, $args, $id) = @_;

    if (!defined $args) {
        send_message($token, $chat, "Nyothing to owofy (^ ^;)", $id);
    }
    else {
        my %map = (
        'r' => 'w',
        'l' => 'w',
        'n' => 'ny'
        );

        my $chars = join '|', keys %map;
        $args =~ s/($chars)/$map{lc $1}/ig;
        send_message($token, $chat, $args, $id);
    }
}

sub suicide_prevention
{
    my ($token, $chat, $uname, $id) = @_;
    my $res = "Crippling Depression is a severe case of depression Only the saddest people has this sickness.  \N{U+1F914}  @".$uname." .....May u get over it \N{U+1F64F}";
    send_message($token, $chat, $res, $id);
}

1;
