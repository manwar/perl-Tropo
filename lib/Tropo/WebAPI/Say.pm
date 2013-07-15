package Tropo::WebAPI::Say;

use strict;
use warnings;

use Moo;
use Types::Standard qw(Int Str Bool ArrayRef Dict);
use Type::Tiny;

extends 'Tropo::WebAPI::Base';

Tropo::WebAPI::Base::register();

our $VERSION = 0.01;

has value => (
    is       => 'ro',
    isa      => Str,
    required => 1,
);

has as => (
    is  => 'ro',
    isa => Str,
);

has event => (
    is  => 'ro',
    isa => Str,
);

has voice => (
    is  => 'ro',
    isa => Int,
);

has allow_signals => (
    is  => 'ro',
    isa => ArrayRef[],
);

sub BUILDARGS {
   my ( $class, @args ) = @_;
 
  unshift @args, "value" if @args % 2 == 1;
 
  return { @args };
}

1;
