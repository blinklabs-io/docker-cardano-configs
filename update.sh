#!/usr/bin/env bash

cd config
for network in sanchonet preview preprod mainnet; do
	mkdir -p $network
	cd $network && \
		for filename in checkpoints.json config{,-bp}.json guardrails-script.plutus peer-snapshot.json topology{,-{genesis-mode,non-bootstrap-peers}}.json {byron,shelley,alonzo,conway,dijkstra}-genesis.json; do
			curl -sL https://book.play.dev.cardano.org/environments/$network/$filename | sed \
				-e 's/127.0.0.1/0.0.0.0/' > $filename
			test -s $filename || rm -f $filename
		done
		grep "404.*Not Found" *.json *.plutus 2>/dev/null | cut -d: -f1 | sort -u | xargs rm -f
	cd ..
done

for network in preview preprod mainnet; do
	baseurl=https://raw.githubusercontent.com/input-output-hk/mithril/refs/heads/main/mithril-infra/configuration
	prefix=release
	if [[ $network == "preview" ]]; then
	       prefix=pre-release
	fi
	cd $network && \
		for filename in ancillary.vkey genesis.vkey; do
			curl -sLo $filename $baseurl/$prefix-$network/$filename
			test -s $filename || rm -f $filename
		done
		grep "404.*Not Found" *.vkey | cut -d: -f1 | sort -u | xargs rm -f
	cd ..
done

if [[ "${HAIL_HYDRA:-false}" == "true" ]]; then
	network=devnet
	baseurl=https://raw.githubusercontent.com/cardano-scaling/hydra/refs/heads/master/hydra-cluster/config
	mkdir -p $network
	cd $network && \
		curl -sL $baseurl/$network/cardano-node.json | sed \
			-e 's/genesis-byron/byron-genesis/g' \
			-e 's/genesis-shelley/shelley-genesis/g' \
			-e 's/genesis-alonzo/alonzo-genesis/g' \
			-e 's/genesis-conway/conway-genesis/g' \
			-e 's/genesis-dijkstra/dijkstra-genesis/g' \
		> config.json
		for genesis in byron shelley alonzo conway dijkstra; do
			curl -sLo $genesis-genesis.json $baseurl/$network/genesis-$genesis.json
			test -s $genesis-genesis.json || rm -f $genesis-genesis.json
		done
		grep "404.*Not Found" *-genesis.json 2>/dev/null | cut -d: -f1 | sort -u | xargs rm -f
		mkdir -p keys && cd keys
		for filename in kes.skey vrf.skey opcert.cert byron-delegat{ion.cert,e.key}; do
			curl -sLo $filename $baseurl/$network/$filename
		done
		cd ..
	cd ..
fi

if [[ "${LEIOS_GO_BRR:-false}" == "true" ]]; then
	network=leios
	target=musashi
	ref=next-2026-05-15
	baseurl=https://raw.githubusercontent.com/input-output-hk/cardano-playground/refs/heads/$ref/docs/environments-pre
	mkdir -p $target
	cd $target && \
		for filename in checkpoints.json config{,-bp}.json guardrails-script.plutus peer-snapshot.json topology{,-{genesis-mode,non-bootstrap-peers}}.json {byron,shelley,alonzo,conway,dijkstra}-genesis.json; do
			curl -sL $baseurl/$network/$filename | sed \
				-e 's/127.0.0.1/0.0.0.0/' > $filename
			test -s $filename || rm -f $filename
		done
		grep "404.*Not Found" *.json *.plutus 2>/dev/null | cut -d: -f1 | sort -u | xargs rm -f
	cd ..
fi
