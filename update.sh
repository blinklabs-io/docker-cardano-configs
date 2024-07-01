#!/usr/bin/env bash

cd config
for network in sanchonet preview preprod mainnet; do
	cd $network && \
		for filename in config.json config-bp.json topology.json {byron,shelley,alonzo,conway}-genesis.json; do
       			curl -sLo $filename https://book.play.dev.cardano.org/environments/$network/$filename
			sed -i -e 's/127.0.0.1/0.0.0.0/' $filename
		done
	cd ..
done
