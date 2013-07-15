package Tropo::WebAPI::Call;

# ABSTRACT: "Call" someone via Tropo API

use strict;
use warnings;

use Moo;
use Types::Standard qw(Int Str Bool ArrayRef Dict);
use Type::Tiny;

extends 'Tropo::WebAPI::Base';

Tropo::WebAPI::Base::register();

our $VERSION = 0.01;

has to => (
    is       => 'ro',
    isa      => Str,
    required => 1,
);

has from => (
    is  => 'ro',
    isa => Str,
    exclude_from_json => 1,
);

has ['network', 'channel'] => (
    is  => 'ro',
    isa => Str,
);

has 'answer_on_media' => (
    is  => 'ro',
    isa => Bool,
);

has timeout => (
    is  => 'ro',
    isa => Int,
);

has headers => (
    is  => 'ro',
    isa => ArrayRef[Str],
);

has recording => (
    is  => 'ro',
    isa => Dict[
        name => Str,
    ],
);

has allow_signals => (
    is  => 'ro',
    isa => ArrayRef[],
);

sub BUILDARGS {
   my ( $class, @args ) = @_;
 
  unshift @args, "to" if @args % 2 == 1;
 
  return { @args };
}

1;
