package Bio::Roary::External::Blastp;

# ABSTRACT: Wrapper around NCBIs blastp command

=head1 SYNOPSIS

Wrapper around NCBIs blastp command

   use Bio::Roary::External::Blastp;
   
   my $blast_database= Bio::Roary::External::Blastp->new(
     fasta_file => 'contigs.fa',
     blast_database => 'db',
     exec       => 'blastp',
     output_file => 'results.out'
   );
   
   $blast_database->run();

=method result_file

Returns the path to the results file

=cut

use Moose;
with 'Bio::Roary::JobRunner::Role';

has 'fasta_file'        => ( is => 'ro', isa => 'Str', required => 1 );
has 'blast_database'    => ( is => 'ro', isa => 'Str', required => 1 );
has 'exec'              => ( is => 'ro', isa => 'Str', default  => 'blastp' );
has '_evalue'           => ( is => 'ro', isa => 'Num', default  => 1E-6 );
has '_num_threads'      => ( is => 'ro', isa => 'Int', default  => 1 );
has '_max_target_seqs'  => ( is => 'ro', isa => 'Int', default  => 2000 );
has '_logging'          => ( is => 'ro', isa => 'Str', default  => '2> /dev/null' );
has 'output_file'       => ( is => 'ro', isa => 'Str', default  => 'results.out' );
has 'perc_identity'     => ( is => 'ro', isa => 'Num', default  => 98 );

sub _command_to_run {
    my ($self) = @_;
    return join(
        " ",
        (
            $self->exec,  
            '-query', $self->fasta_file, 
            '-db', $self->blast_database, 
            '-evalue', $self->_evalue,
            '-num_threads', $self->_num_threads,
            '-outfmt 6',
            '-max_target_seqs', $self->_max_target_seqs,
            ' | awk \'{ if ($3 > '.$self->perc_identity.') print > "'.$self->output_file.'"; else print > "'.$self->output_file.'.filtered"}\'',  
            $self->_logging,
        )
        
        
    );
}

sub run {
    my ($self) = @_;
	$self->logger->info( "Running command: " . $self->_command_to_run() );
    system( $self->_command_to_run );
    1;
}

no Moose;
__PACKAGE__->meta->make_immutable;
1;
