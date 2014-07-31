#!/usr/bin/perl
use warnings;
use strict;
use Bio::SeqIO;
use Bio::DB::GenBank;
   
my $file         = shift; # get the file name, somehow
my $a=shift;
my $seqio_object = Bio::SeqIO->new(-file => $file,-format => 'fasta',);

 
open(my $qiime, ">>", "qiime.txt") 
	or die "cannot open > qiime.txt: $!";
open(my $fasta, ">>", "fasta.txt") 
	or die "cannot open > fasta.txt: $!";

if ($a == undef){
$a = '000000';
}


while (my $seq = $seqio_object->next_seq) {
    my $desc= $seq->desc;
    my $acc= $seq->id;
    print "ACCESSION NO ".$acc."\n";
	my $gb = new Bio::DB::GenBank;
	my $gbseq = $gb->get_Seq_by_acc($acc); # Accession Number
    my $gbspecies = $gbseq->species();
    my $gb_gen= $gbspecies->genus." ";
	my $gb_spec= $gbspecies->species;
	my $species=$gb_gen.$gb_spec;
	print "SPECIES ID ".$species."\n";
	my $server_endpoint = "http://www.indexfungorum.org/ixfwebservice/fungus.asmx/NameSearchDs";
	my $post_data=gen_post(\$species);

	#RETRIEVE SPECIES ID
	my $message = retrieve_post(\$server_endpoint,\$post_data);
	#print "Received reply: $message\n";
	my %parsed_message=parse_message(\$message);
	
	
	my %new=%{$parsed_message{'diffgr:diffgram'}};	
	
	#WORKAROUND FOR SPECIES NOT IN DATABASE
	if (exists $new{'NewDataSet'}){
		print "OK";
	}
	else{
		next;
	}
	
	
	my %new1=%{$new{'NewDataSet'}};
	my %new2=%{$new1{'IndexFungorum'}};
	my $name=$new2{'NAME_x0020_OF_x0020_FUNGUS'};
	my $key=$new2{'RECORD_x0020_NUMBER'};

	#PRINT FINDINGS
	print $name."\n";
	print $key."\n";
#exit;

	#RETRIEVE TAXONOMY
	$server_endpoint = "http://www.indexfungorum.org/ixfwebservice/fungus.asmx/NameByKey";
	$post_data = 'NameKey='.$key;
	print "Query ".$post_data."\n";
	$message = retrieve_post(\$server_endpoint,\$post_data);
	#print "Received reply: $message\n";

	#PARSE TAXONOMY
	my %parsed_tax=parse_message(\$message);
	my %tax=%{$parsed_tax{'IndexFungorum'}};
	my $genus=$tax{'Genus_x0020_name'};
	my $family=$tax{'Family_x0020_name'};
	my $order=$tax{'Order_x0020_name'};
	my $subclass=$tax{'Subclass_x0020_name'};
	my $class=$tax{'Class_x0020_name'};
	my $subphylum=$tax{'Subphylum_x0020_name'};
	my $phylum=$tax{'Phylum_x0020_name'};
	my $kingdom= $tax{'Kingdom_x0020_name'};


	###TEST QIIME OUTPUT###
	
	$a++;
	print "SH".$a.".14OM_".$key."_reps\t";
	print "k__".$kingdom.";p__".$phylum.";c__".$class.";o__".$order.";f__".$family.";g__".$genus.";s__".$name."\n";
	#>SH000001.06FU_JQ347180_reps
	print ">SH".$a.".14OM_".$key."_reps\n";
	print $gbseq->seq();
	
	print $qiime "SH".$a.".14OM_".$key."_reps\t";
	print $qiime "k__".$kingdom.";p__".$phylum.";c__".$class.";o__".$order.";f__".$family.";g__".$genus.";s__".$name."\n";
	#>SH000001.06FU_JQ347180_reps
	print $fasta ">SH".$a.".14OM_".$key."_reps\n";
	print $fasta $gbseq->seq()."\n";

}



sub gen_post{
my ($species)=@_;
my $post_data="SearchText=".$$species."&AnywhereInText=TRUE&MaxNumber=1";
return $post_data;
}

sub parse_message{
my ($message)=@_;
use XML::Simple;
use Data::Dumper;

my $xml = new XML::Simple;
# read XML file
my $data = $xml->XMLin($$message);
# print output
#print Dumper($data);
print "Parsed into hash\n";
return %{$data};
}





sub retrieve_post{
my ($server_endpoint, $post_data)=@_;

use LWP::UserAgent; 
my $ua = LWP::UserAgent->new; 
my $req = HTTP::Request->new(POST => $$server_endpoint);
$req->header('content-type' => 'application/x-www-form-urlencoded');
#$req->header('length' => '1');
$req->content($$post_data);
my $resp = $ua->request($req);
my $message=();
	if ($resp->is_success) {
	    $message = $resp->decoded_content;  
 	   print "Received reply\n"
	}
	else {
 	   print "HTTP POST error code: ", $resp->code, "\n";
 	   print "HTTP POST error message: ", $resp->message, "\n";
 	   $message = "FAIL";
	}
return $message;
}

