DURATION_RW=1800 # 30-minute runs r/w
DURATION_RO=900  # 15-minute runs r/o
RUNS=3
CLIENTS="1 4 16"
OUTDIR=$1

function log {
	echo `date +%s` `date +"%Y-%m-%d %H:%M:%S"` $1
}

# three scales 30 (450MB), 300 (4.5GB), 1500 (22GB)
for s in 30 300 1500; do

	# three runs for each combination
	for r in `seq 1 $RUNS`; do

		outdir="$OUTDIR/$s/$r"
		mkdir -p $outdir

		log "pgbench scale=$s run=$r"

		# recreate the db
		dropdb --if-exists pgbench > /dev/null 2>&1
		createdb pgbench > /dev/null 2>&1

		log "pgbench scale=$s run=$r : init"

		# initialize
		pgbench -i -s $s -q pgbench > /dev/null 2>&1

		log "pgbench scale=$s run=$r : warmup"

		# warmup (read-only)
		pgbench -S -c 4 -T $DURATION_RO pgbench > $outdir/warmup.log 2>&1

		# a few basic client counts
		for c in $CLIENTS; do

			# do a checkpoint first
			psql pgbench -c "checkpoint" > /dev/null 2>&1

			log "pgbench scale=$s run=$r clients=$c : read-only"

			# read-only test
			pgbench -S -c $c -T $DURATION_RO pgbench > $outdir/read-only-$c.log 2>&1

			# do a checkpoints first
			psql pgbench -c "checkpoint" > /dev/null 2>&1

			log "pgbench scale=$s run=$r clients=$c : read-write"

			# read-write test
			pgbench -c $c -T $DURATION_RW pgbench > $outdir/read-write-$c.log 2>&1

		done

		log "pgbench scale=$s clients=$c run=$r : done"

	done

done
