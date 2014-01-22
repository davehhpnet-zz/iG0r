#!/usr/bin/env perl

use POE;
use POE::Component::IRC::State;
use POE::Component::IRC::Plugin::AutoJoin;
use URI::Title qw / title /;

use strict;
use warnings;

POE::Session->create(
    package_states => [ main => [qw/ _default _start irc_join /] ] );

$poe_kernel->run();

sub _start {
    my $irc = POE::Component::IRC::State->spawn(
        Nick   => 'iG0r',
        Server => 'teodesian.net',
        Port => '6697',
        UseSSL => 'true',
    );

    $irc->plugin_add(
        'AutoJoin',
        POE::Component::IRC::Plugin::AutoJoin->new(
             Channels => [ '#liberty', ]
        )
    );

    $irc->yield( register => 'join' );
    $irc->yield('connect');
}

sub irc_join {
    my $nick    = ( split /!/, $_[ARG0] )[0];
    my $channel = $_[ARG1];
    my $irc     = $_[SENDER]->get_heap();

    # only send the message if we were the one joining
    if ( $nick eq $irc->nick_name() ) {
        $irc->yield( privmsg => $channel, 'Hello, Masters... o_O' );
        $irc->yield( ctcp => $channel => 'ACTION staggers into the room' );
    }
}

sub _default {
    my ( $event, $args ) = @_[ ARG0 .. $#_ ];
    my $channel = $_[ARG1][1];
    my $user = (split /!/, $_[ARG1][0])[0];
    my $message = $_[ARG1][2];
    my @output = ("$event: ");
    my $irc = $_[SENDER]->get_heap();

    for my $arg ($args) {
        if ( ref $arg eq 'ARRAY' ) {
            push( @output, '[' . join( ', ', @$arg ) . ']' );
        }
        else {
            push( @output, "'$arg'" );
        }
    }
    print join ' ', @output, "\n";

    use Data::Dumper;
    print Dumper($_[ARG1][2]);

    if ( $event eq 'irc_public' && $user =~/y000da*/ && $message eq 'you stink' ) {
        $irc->yield( privmsg => $channel, 'Sorry about that.  I had Mexican for lunch heh, ' . $user );
    }
    if ( $event eq 'irc_public' && $message =~ /(^|\s+)(black|brown|yellow|red|green|blue|purple|gray|indigo|chartrues|orange|liberal(s*))(\s+|$)/i ) {
        $irc->yield( privmsg => $channel, 'That\'s racist, ' . $user . '. http://zen.thehhp.net/albums/funny/thats_racist_wtf.gif' );
    }
    if ( $event eq 'irc_public' && $message =~ /(^|\s+)(build|rebuilt|built)(\s+|$)/i ) {
        $irc->yield( privmsg => $channel, 'Pfft, ' . $user . '. http://zen.thehhp.net/albums/liberty/OBAMA-you_didnt_build_that.jpg' );
    }
    if ( $event eq 'irc_public' && $message =~ /(https?:\/\/[www.]?\w.*)/i ) {
        print "DDDD REGEX: $1\n";
        my $title = title($1);
        print "TITLE-->$title\n" if defined $title;
        $irc->yield( privmsg => $channel, "<-[ $title ]->" ) if defined $title;;
    }
    return 0;
}
