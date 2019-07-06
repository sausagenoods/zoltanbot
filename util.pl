use strict;
use warnings;

use JSON qw( );

sub decode_json {
    my ($text) = @_;
    my $json = JSON->new;
    return $json->decode($text);
}

sub load_config {
    my ($cfg) = @_;

    my $json_text = do {
        open(my $json_fh, "<", $cfg) or die("Couldn't open \$cfg\!");
        local $/;
        <$json_fh>
    };

    return decode_json($json_text);
}

1;
