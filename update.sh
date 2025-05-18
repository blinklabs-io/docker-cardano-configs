#!/usr/bin/env bash

cd config
for network in sanchonet preview preprod mainnet; do
	mkdir -p $network
	cd $network && \
		for filename in checkpoints.json config{,-bp}.json peer-snapshot.json topology{,-{genesis-mode,non-bootstrap-peers}}.json {byron,shelley,alonzo,conway}-genesis.json; do
			curl -sL https://book.play.dev.cardano.org/environments/$network/$filename | sed \
				-e 's/127.0.0.1/0.0.0.0/' > $filename
			test -s $filename || rm -f $filename
		done
		grep "404 Not Found" *.json | cut -d: -f1 | sort -u | xargs rm -f
	cd ..
done

if [[ ${HAIL_HYDRA:-false} ]]; then
	network=devnet
	baseurl=https://raw.githubusercontent.com/cardano-scaling/hydra/refs/heads/master/hydra-cluster/config
	mkdir -p $network
	cd $network && \
		curl -sL $baseurl/$network/cardano-node.json | sed \
			-e 's/genesis-byron/byron-genesis/g' \
			-e 's/genesis-shelley/shelley-genesis/g' \
			-e 's/genesis-alonzo/alonzo-genesis/g' \
			-e 's/genesis-conway/conway-genesis/g' \
		> config.json
		for genesis in byron shelley alonzo conway; do
			curl -sLo $genesis-genesis.json $baseurl/$network/genesis-$genesis.json
		done
		mkdir -p keys && cd keys
		for filename in kes.skey vrf.skey opcert.cert byron-delegat{ion.cert,e.key}; do
			curl -sLo $filename $baseurl/$network/$filename
		done
		cd ..
	cd ..
fi
