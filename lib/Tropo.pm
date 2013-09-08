package Tropo;

# ABSTRACT: Use the TropoAPI via Perl

use strict;
use warnings;

use Moo;
use Types::Standard qw(ArrayRef);
use Path::Tiny;
use JSON;

use overload '""' => \&json;

our $VERSION = 0.14;

has objects => (
    is      => 'rw',
    isa     => ArrayRef,
    default => sub { [] },
);

for my $subname ( qw(call say ask on wait) ) {
    my $name     = ucfirst $subname;
    my @parts    = qw/Tropo WebAPI/;
    
    my $filename = path( @parts, $name . '.pm' );
    require $filename;
    
    my $module = join '::', @parts, $name;
    
    no strict 'refs';
    
    *{"Tropo::$subname"} = sub {
        my ($tropo,@params) = @_;
        
        my $obj = $module->new( @params );
        $tropo->add_object( { $subname => $obj } );

        return $tropo;
    };
}

sub perl {
    my ($self) = @_;
    
    my @objects;
    my $last_type = '';
    
    for my $index ( 0 .. $#{ $self->objects } ) {
        my $object      = $self->objects->[$index];
        my $next_object = $self->objects->[$index+1];

        my ($type,$obj) = %{ $object };
        my ($next_type) = %{ $next_object || { '' => ''} };

        if ( $type ne $last_type && $type eq $next_type && $type ne 'on' ) {
            push @objects, { $type => [ $obj->to_hash ] };
        }
        elsif ( $type ne $last_type && $type ne $next_type || $type eq 'on' ) {
            push @objects, { $type => $obj->to_hash };
        }
        else {
            push @{ $objects[-1]->{$type} }, $obj->to_hash;
        }

        $last_type = $type;
    }
    
    my $data = {
        tropo => \@objects,
    };
    
    return $data;
}

sub json {
    my ($self) = @_;
    
    my $data   = $self->perl;
    my $string = JSON->new->encode( $data );
    
    return $string;
}

sub add_object {
    my ($self, $object) = @_;
    
    return if !$object;
    
    push @{ $self->{objects} }, $object;
}

1;

__END__
=head1 DESCRIPTION

=head1 SYNOPSIS

Ask the 

  my $tropo = Tropo->new;
  $tropo->call(
    to => $clients_phone_number,
  );
  $tropo->say( 'hello ' . $client_name );
  $tropo->json;

Creates this JSON output:

  {
      "tropo":[
          {
              "call": {
                      "to":"+14155550100"
              }
          },
          {
              "say": [
                  {
                      "value":"Tag, you're it!"
                  }
              ]
          }
      ]
  }

=head1 HOW THE TROPO API WORKS

The Tropo server I<talks> with your web application via json sent with HTTP POST requests.

When you'd like to initiate a call/text message, you have to start a session.

        my $session = Tropo::RestAPI::Session->new(
            url => 'https://tropo.developergarden.com/api/', # use developergarden.com api
        );

        my $data = $session->create(
            token        => $token,
            call_session => $id,
        ) or print $session->err;

When you create a session you can pass any parameter you want. The only mandatory parameter
is I<token>. You'll find that token in your developergarden account in the application management.

The Tropo server then requests the URI that you added in the application management. It is an
HTTP POST request that contains a session id and some more

=head1 COMMANDS

This list show the commands currently implemented. This library is under heavy development,
so that more commands will follow in the near future:

=head2 ask

=head2 call

=head2 on

=head2 say

=head2 wait

A detailed description of all commands and their attributes can be found at
L<http://www.developergarden.com/fileadmin/microsites/ApiProject/Dokumente/Dokumentation/Api_Doc_5_0/telekom-tropo-2.1/html/method_summary.html|DeveloperGarden>.

=head1 EXAMPLES

All examples can be found in the I<examples> directory of this distribution. Those examples
might have extra dependencies that you might have to install when you want to run the code.

You also need an account e.g. for developergarden.com or tropo.com.

=head2 Two factor authentication

I<call_customer.psgi>

You can find a small C<Mojolicious::Lite> application that calls a customer to tell him a
code... On the start page a small form is shown where the customer sends his phone number.
Then a new call is initiated and the Tropo provider calls the customer and tells him the
secret.

=head2 Handle incoming calls

I<televote.psgi>

You can publish a phonenumber that is connected to your application (e.g. in developergardens
application management).

=head1 ACKNOWLEDGEMENT

I'd like to thank Richard from Telekoms Developergarden. He has done a lot of debugging during
the #startuphack (Hackathon at "Lange Nacht der Startups" 2013).

=cut
