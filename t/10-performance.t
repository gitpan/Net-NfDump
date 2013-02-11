
use Test::More tests => 1;
use Net::NfDump qw ':all';
use Data::Dumper;
#open(STDOUT, ">&STDERR");
our %DS;

require "t/ds.pl";

# testing performance 
diag "";
diag "Testing hashref performance, it will take while...";
my $recs = 100000;

my %tests = ( 'v4_basic_raw' => 'basic items', 'v4_raw' => 'all items' );

while (my ($key, $val) = each %tests ) {
	my $rec = $DS{$key} ;
	my $flow = new Net::NfDump(OutputFile => "t/flow_$key.tmp" );
	my $tm1 = time();
	for (my $x = 0 ; $x < $recs; $x++) {
		$flow->storerow_hashref( $rec );
	}
	$flow->finish();

	my $tm2 = time() - $tm1;
	diag sprintf("Write performance %s, written %d recs in %d secs (%.3f/sec)", $val, $recs, $tm2, $recs/$tm2);
}


while (my ($key, $val) = each %tests ) {
	my $flow = new Net::NfDump(InputFiles => [ "t/flow_$key.tmp" ] );
	my $tm1 = time();
	my $cnt = 0;
	$flow->query();
	while ( $row = $flow->fetchrow_hashref() )  {
		$cnt++ if ($row);
	}
	$flow->finish();

	my $tm2 = time() - $tm1;
	diag sprintf("Read performance %s, read %d recs in %d secs (%.3f/sec)", $val, $cnt, $tm2, $recs/$tm2);
}

diag "Testing arrayref performance, it will take while...";
$recs = 2000000;

%tests = ( 'v4_basic_raw' => 'basic items', 'v4_raw' => 'all items' );

while (my ($key, $val) = each %tests ) {
	my @fields  = keys %{$DS{$key}};
	my $rec = [ values %{$DS{$key}} ];
	my $flow = new Net::NfDump(OutputFile => "t/flow_$key.tmp", Fields => [ @fields ] );
	my $tm1 = time();
	for (my $x = 0 ; $x < $recs; $x++) {
		$flow->storerow_arrayref( $rec );
	}
	$flow->finish();

	my $tm2 = time() - $tm1;
	diag sprintf("Write performance %s, written %d recs in %d secs (%d/sec)", $val, $recs, $tm2, $recs/$tm2);
}


while (my ($key, $val) = each %tests ) {
	my @fields  = keys %{$DS{$key}};
	my $flow = new Net::NfDump(InputFiles => [ "t/flow_$key.tmp" ], Fields => [ @fields ] );
	my $tm1 = time();
	my $cnt = 0;
	$flow->query();
	while ( $row = $flow->fetchrow_arrayref() )  {
		$cnt++ if ($row);
	}
	$flow->finish();

	my $tm2 = time() - $tm1;
	diag sprintf("Read performance %s, read %d recs in %d secs (%d/sec)", $val, $cnt, $tm2, $recs/$tm2);
}

ok(1);

