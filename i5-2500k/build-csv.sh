for d in 2.* 3.* 4.*; do

	for s in 30 300 1500; do

		for t in read-only read-write; do

			for c in 1 4 16; do

				for r in 1 2 3; do

					tps=`cat $d/$s/$r/$t-$c.log | grep excluding | awk '{print $3}'`

					echo $d	$s	$t	$r	$c	$tps

				done

			done

		done

	done

done
