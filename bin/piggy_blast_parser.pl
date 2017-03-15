#!/usr/bin/perl -w

$in_blast_file=$ARGV[0];
$in_file=$ARGV[1];
$out_file=$ARGV[2];

open OUTPUT, ">$out_file";

open INPUT, $in_blast_file;
while(<INPUT>){
	$line=$_;
	chomp $line;
	@line_array=split(/\s+/, $line);
	
	if($line_array[0] eq $line_array[1]){
		$seq_header_hash{$line_array[0]}=$line_array[3];
	}
}

@seq_header_array=keys(%seq_header_hash);
@seq_header_array=sort(@seq_header_array);
$seq_header_count=scalar(@seq_header_array);

$hits=0;
if($seq_header_count > 1){
	open INPUT, $in_blast_file;
	while(<INPUT>){
		$line=$_;
		chomp $line;
		@line_array=split(/\s+/, $line);
	
		if($line_array[0] eq $seq_header_array[0] && $line_array[1] eq $seq_header_array[1]){
			$hits++;
		}
	}
}

if($hits > 0){
	print STDOUT "hit";
}else{
	print STDOUT "no_hit";
	
	open FASTA, "$in_file";
	while(<FASTA>){
		$line=$_;
		chomp $line;

		if($line =~ /^>(.+)/){
			$id=$1;
		}elsif($line =~ /^([ATGCN]+)/){
			$seq=$1;
			$len=length($seq);
	
			@tmp_array=("$id", "$seq", "$len");
	
			push @seq_array, [@tmp_array];
		}
	}

	print OUTPUT ">$seq_array[0][0]\n";
	print OUTPUT "$seq_array[0][1]";
	for($i=0; $i<$seq_array[1][2]; $i++){
		print OUTPUT "-";
	}
	print OUTPUT "\n";

	print OUTPUT ">$seq_array[1][0]\n";
	for($i=0; $i<$seq_array[0][2]; $i++){
		print OUTPUT "-";
	}
	print OUTPUT "$seq_array[1][1]";
	print OUTPUT "\n";
}

