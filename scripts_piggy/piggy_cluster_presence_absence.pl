#!/usr/bin/env perl
use warnings;
use strict;

my $out_dir=$ARGV[0];

print STDOUT "Producing IGR presence absence matrix...\n";
print STDERR "Producing IGR presence absence matrix...\n";

open OUTPUT, ">$out_dir/IGR_presence_absence.csv" or die "Cannot open output file: $out_dir/IGR_presence_absence.csv\n";
open OUTPUT_RTAB, ">$out_dir/IGR_presence_absence.Rtab" or die "Cannot open output file: $out_dir/IGR_presence_absence.Rtab\n";

my @isolate_array=();

open INPUT, "$out_dir/isolates.txt" or die "Input file doesn't exist: $out_dir/isolates.txt\n";
while(my $line=<INPUT>){
	chomp $line;
	
	push @isolate_array, $line;
}
close INPUT;

my @cluster_array=();

open INPUT, "$out_dir/clusters.txt" or die "Input file doesn't exist: $out_dir/clusters.txt\n";
while(my $line=<INPUT>){
	chomp $line;
	
	push @cluster_array, $line;
}
close INPUT;

my %cluster_isolate_count_hash=();
my %cluster_seq_count_hash=();
my %cluster_hash=();

foreach my $cluster(@cluster_array){
	open INPUT, "$out_dir/cluster_intergenic_files/$cluster.fasta" or die "Input file doesn't exist: $out_dir/cluster_intergenic_files/$cluster.fasta\n";
	while(my $line=<INPUT>){
		chomp $line;
	
		if($line =~ /^>(.+)/){
			
			my $cluster_id=$1;
			my @cluster_id_array=split(/_\+_\+_/, $cluster_id);
			my $isolate=$cluster_id_array[0];
		
			if(!$cluster_hash{$cluster}{$isolate}){
				$cluster_isolate_count_hash{$cluster}++;
			
				$cluster_hash{$cluster}{$isolate}=$cluster_id;
			}else{
				$cluster_hash{$cluster}{$isolate}="$cluster_hash{$cluster}{$isolate}\t$cluster_id";
			}
		
			$cluster_seq_count_hash{$cluster}++;
		}
	}
}

my @cluster_sorted_array=sort { $cluster_isolate_count_hash{$b} <=> $cluster_isolate_count_hash{$a} } keys %cluster_isolate_count_hash;

print OUTPUT "\"Gene\",\"Non-unique Gene name\",\"Annotation\",\"No. isolates\",\"No. sequences\",\"Avg sequences per isolate\",\"Genome Fragment\",\"Order within Fragment\",\"Accessory Fragment\",\"Accessory Order with Fragment\",\"QC\",\"Min group size nuc\",\"Max group size nuc\",\"Avg group size nuc\"";
print OUTPUT_RTAB "Gene";

foreach my $isolate(@isolate_array){
	print OUTPUT ",\"$isolate\"";
	print OUTPUT_RTAB "\t$isolate";
}
print OUTPUT "\n";
print OUTPUT_RTAB "\n";

foreach my $cluster(@cluster_sorted_array){
	my $ave_seqs=($cluster_seq_count_hash{$cluster}/$cluster_isolate_count_hash{$cluster});
	
	print OUTPUT "\"$cluster\",\"\",\"\",\"$cluster_isolate_count_hash{$cluster}\",\"$cluster_seq_count_hash{$cluster}\",\"$ave_seqs\",\"\",\"\",\"\",\"\",\"\",\"\",\"\",\"\"";
    print OUTPUT_RTAB "$cluster";
	foreach my $isolate(@isolate_array){
		if($cluster_hash{$cluster}{$isolate}){
			print OUTPUT ",\"$cluster_hash{$cluster}{$isolate}\"";
			print OUTPUT_RTAB "\t1";
		}else{
			print OUTPUT ",\"\"";
			print OUTPUT_RTAB "\t0";
		}
	}
	print OUTPUT "\n";
	print OUTPUT_RTAB "\n";
}

print STDOUT "IGR presence absence matrix produced.\n";
print STDERR "IGR presence absence matrix produced.\n";

