use strict;
use warnings;

sub ask_ball
{
    my ($args, $id) = @_;
   
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
        send_message("Ask me something.", $id);
    }
    elsif ($args =~ /(what|who|when|why|whose|when|how)/) {
        send_message("Ask me a yes-no question instead.", $id);
    }
    else {
    send_message($answers[rand @answers], $id); 
    }
} 

sub urban_dictionary
{
    my ($args, $id) = @_;

    if (!defined $args) {
        send_message("Nothing to look up for.", $id);
    }

    my $url = "http://api.urbandictionary.com/v0/define?term=${args}";
    my $content = get($url);
    my $json = decode_json($content);

    if ($json->{list}[0]) {
        my $definition = $json->{list}[0]->{definition};
        send_message($definition, $id);
    }
    else {
        send_message("Definition not found.", $id);
    }
}

our @sudo_users;

sub execute
{
    my ($user, $args, $id) = @_;
    if ($user ~~ @sudo_users) {
        if (!defined $args) {
            send_message("Nothing to execute.", $id);
        }
        else {
            my $out = `${args} 2>&1`;
            send_message($out, $id);
        }
    }
    else {
        send_message("You're not allowed to execute.", $id);
    }
}

sub owofy
{
    my ($args, $id) = @_;

    if (!defined $args) {
        send_message("Nyothing to owofy (^ ^;)", $id);
    }
    else {
        my %map = (
        'r' => 'w',
        'l' => 'w',
        'n' => 'ny'
        );

        my $chars = join '|', keys %map;
        $args =~ s/($chars)/$map{lc $1}/ig;
        send_message($args, $id);
    }
}

sub suicide_prevention
{
    my ($uname, $id) = @_;
    my $res = "Crippling Depression is a severe case of depression Only the saddest people has this sickness.  \N{U+1F914}  @".$uname." .....May u get over it \N{U+1F64F}";
    send_message($res, $id);
}

1;
