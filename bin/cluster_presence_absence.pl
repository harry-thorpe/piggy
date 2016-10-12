#!/usr/bin/perl -w

$in_dir=$ARGV[0];
$out_dir=$ARGV[1];

open LOG, ">>$out_dir/log.txt";

open OUTPUT, ">$out_dir/IGR_presence_absence.csv";

open INPUT, "$out_dir/isolates.txt";
while(<INPUT>){
	$line=$_;
	chomp $line;
	
	push @isolate_array, $line;
}

open INPUT, "$out_dir/output_fasta_clustered.fasta.clstr";
while(<INPUT>){
	$line=$_;
	chomp $line;
	
	if($line =~ /^>(.+)/){
		$cluster=$1;
		$cluster=~s/ /_/g;
	
	}elsif($line =~ /^\d+\s+\d+nt,\s+\>(\S+)\.\.\./){
		$cluster_id=$1;
		@cluster_id_array=split(/_\+_\+_/, $cluster_id);
		$isolate=$cluster_id_array[0];
		
		if(!$cluster_hash{$cluster}{$isolate}){
			$cluster_isolate_count_hash{$cluster}++;
			
			$cluster_hash{$cluster}{$isolate}=$cluster_id;
		}else{
			$cluster_hash{$cluster}{$isolate}="$cluster_hash{$cluster}{$isolate}\t$cluster_id";
		}
		
		$cluster_seq_count_hash{$cluster}++;
	}
}

@cluster_array=sort { $cluster_isolate_count_hash{$b} <=> $cluster_isolate_count_hash{$a} } keys %cluster_isolate_count_hash;

print OUTPUT "Cluster,Isolates,Sequences";
foreach $isolate(@isolate_array){
	print OUTPUT ",$isolate";
}
print OUTPUT "\n";

foreach $cluster(@cluster_array){
	
	print OUTPUT "$cluster,$cluster_isolate_count_hash{$cluster},$cluster_seq_count_hash{$cluster}";
	foreach $isolate(@isolate_array){
		if($cluster_hash{$cluster}{$isolate}){
			print OUTPUT ",$cluster_hash{$cluster}{$isolate}";
		}else{
			print OUTPUT ",";
		}
	}
	print OUTPUT "\n";
}

