package Tropo;

# ABSTRACT: Use the TropoAPI via Perl

use strict;
use warnings;

use Moo;
use Types::Standard qw(ArrayRef);
use Path::Tiny;
use JSON;

use overload '""' => \&json;

our $VERSION = 0.10;

has objects => (
    is      => 'rw',
    isa     => ArrayRef,
    default => sub { [] },
);

for my $subname ( qw(call say) ) {
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
    };
}

sub perl {
    my ($self) = @_;
    
    my @objects;
    my $last_type = '';
    
    for my $object ( @{ $self->objects } ) {
        my ($type,$obj) = %{ $object };
        
        if ( $type ne $last_type ) {
            push @objects, { $type => [ $obj->to_hash ] };
        }
        else {
            push @{ $objects[-1]->{$type} }, $obj->to_hash;
        }
    }
    
    my $data = {
        tropo => \@objects,
    };
    
    return @objects;
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
              "call": [
                  {
                      "to":"+14155550100"
                  }
              ]
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

=cut