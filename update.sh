#!/usr/bin/env bash

cd config
for network in preview preprod mainnet; do
	mkdir -p $network
	cd $network && \
		for filename in checkpoints.json config{,-bp}.json guardrails-script.plutus peer-snapshot.json topology{,-{genesis-mode,non-bootstrap-peers}}.json {byron,shelley,alonzo,conway,dijkstra}-genesis.json tracer-config.json; do
			curl -sL https://book.play.dev.cardano.org/environments/$network/$filename | sed \
				-e 's/127.0.0.1/0.0.0.0/' > $filename
			test -s $filename || rm -f $filename
		done
		grep "404.*Not Found" *.json *.plutus 2>/dev/null | cut -d: -f1 | sort -u | xargs rm -f
	cd ..
done

# DijkstraNet is published separately from the standard environments.
mkdir -p dijkstra
for filename in config.json db-sync-config.json submit-api-config.json topology.json peer-snapshot.json byron-genesis.json shelley-genesis.json alonzo-genesis.json conway-genesis.json dijkstra-genesis.json tracer-config.json guardrails-script.plutus; do
	curl --fail --silent --show-error --location \
		"https://book.play.dev.cardano.org/environments-pre/dijkstra/$filename" \
		--output "dijkstra/$filename" || exit 1
	sed -i 's/127\.0\.0\.1/0.0.0.0/g' "dijkstra/$filename"
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

# config/devnet is maintained in this repository and is deliberately not
# fetched from cardano-scaling/hydra any more. It started as a copy of the
# hydra devnet, but it now diverges on protocol version, slot and epoch
# timing, and Plutus cost models, and re-fetching silently reverted all of
# that. The keys and the Dijkstra genesis are committed alongside it.

if [[ "${LEIOS_GO_BRR:-true}" == "true" ]]; then
	network=leios
	target=musashi
	baseurl=https://book.play.dev.cardano.org/environments-pre
	mkdir -p $target
	cd $target && \
		for filename in checkpoints.json config{,-bp}.json guardrails-script.plutus peer-snapshot.json topology{,-{genesis-mode,non-bootstrap-peers}}.json {byron,shelley,alonzo,conway,dijkstra}-genesis.json tracer-config.json; do
			curl -sL $baseurl/$network/$filename | sed \
				-e 's/127.0.0.1/0.0.0.0/' > $filename
			test -s $filename || rm -f $filename
		done
		grep "404.*Not Found" *.json *.plutus 2>/dev/null | cut -d: -f1 | sort -u | xargs rm -f
	cd ..
fi
