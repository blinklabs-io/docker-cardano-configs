#!/usr/bin/env bash

cd config || exit 1

apex_files=(
	configuration.yaml
	topology.json
	genesis/byron/genesis.json
	genesis/shelley/genesis.json
	genesis/shelley/genesis.alonzo.json
	genesis/shelley/genesis.conway.json
)

for network in prime-testnet prime-mainnet vector-testnet vector-mainnet; do
	case "$network" in
		prime-testnet) source=prime-docker/d915b298b4225d5e8b85869e25fdb8ffe3fcfd9e/testnet/node-10.1.4 ;;
		prime-mainnet) source=prime-mainnet-docker/3e1cf01f5bf8452772e3249ad99181b2c153c730/mainnet/node-10.1.4 ;;
		vector-testnet) source=vector-docker/de7a1061fa7a914cd39577228327a0a81d5abd17/public-testnet/node-10.4.1 ;;
		vector-mainnet) source=vector-mainnet-docker/9bf7c730409141ce53f0f849ac727be6b3f51ae8/mainnet/node-10.5.3 ;;
	esac
	baseurl="https://raw.githubusercontent.com/Apex-Fusion/$source/config/node"
	stage=$(mktemp -d ".${network}.update.XXXXXX") || exit 1
	trap 'rm -rf -- "$stage"' EXIT
	for filename in "${apex_files[@]}"; do
		mkdir -p "$stage/$(dirname "$filename")" || exit 1
		curl --fail --silent --show-error --location \
			"$baseurl/$filename" --output "$stage/$filename" || exit 1
	done
	for filename in "${apex_files[@]}"; do
		mkdir -p "$network/$(dirname "$filename")" || exit 1
		mv -- "$stage/$filename" "$network/$filename" || exit 1
	done
	rm -rf -- "$stage"
	trap - EXIT
done

for network in preview preprod mainnet; do
	mkdir -p $network
	cd $network && \
		for filename in checkpoints.json config{,-bp}.json guardrails-script.plutus peer-snapshot.json topology{,-{genesis-mode,non-bootstrap-peers}}.json {byron,shelley,alonzo,conway,dijkstra}-genesis.json tracer-config.json; do
			curl -sL "https://book.play.dev.cardano.org/environments/$network/$filename" | sed \
				-e 's/127.0.0.1/0.0.0.0/' > "$filename"
			test -s "$filename" || rm -f "$filename"
		done
		grep "404.*Not Found" -- ./*.json ./*.plutus 2>/dev/null | cut -d: -f1 | sort -u | xargs rm -f
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
			curl -sLo "$filename" "$baseurl/$prefix-$network/$filename"
			test -s "$filename" || rm -f "$filename"
		done
		grep "404.*Not Found" -- ./*.vkey | cut -d: -f1 | sort -u | xargs rm -f
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
	mkdir -p "$target"
	cd "$target" && \
		for filename in checkpoints.json config{,-bp}.json guardrails-script.plutus peer-snapshot.json topology{,-{genesis-mode,non-bootstrap-peers}}.json {byron,shelley,alonzo,conway,dijkstra}-genesis.json tracer-config.json; do
			curl -sL "$baseurl/$network/$filename" | sed \
				-e 's/127.0.0.1/0.0.0.0/' > "$filename"
			test -s "$filename" || rm -f "$filename"
		done
		grep "404.*Not Found" -- ./*.json ./*.plutus 2>/dev/null | cut -d: -f1 | sort -u | xargs rm -f
	cd ..
fi
