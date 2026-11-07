# cardano-configs

This repository is used to build a container image holding the configuration
files used for a Cardano Node (Haskell) and other ecosystem applications.

## Overview

This project provides Cardano network configuration files in a container image format. It includes configurations for the following networks:

- mainnet: Cardano's production network.
- preprod: Cardano testnet for testing integrations before mainnet deployment.
- preview: Cardano testnet for previewing upcoming network changes.
- prime-testnet: Apex Fusion Prime testnet for its Ouroboros settlement and staking layer.
- prime-mainnet: Apex Fusion Prime production network for settlement and staking.
- vector-testnet: Apex Fusion Vector testnet for its eUTXO application layer.
- vector-mainnet: Apex Fusion Vector production network for eUTXO applications.
- sanchonet: Cardano testnet for Conway governance features.
- dijkstra: DijkstraNet, a test network for the Dijkstra era (network magic 6).
- musashi: Test network for the Leios prototype.
- devnet: Single-node development network maintained in this repository.

## Usage

### Published Images

Published images are available from both registries:

- Docker Hub: `blinklabs/cardano-configs`
- GitHub Container Registry: `ghcr.io/blinklabs-io/cardano-configs`

Use `latest` for the most recent image, or pin a version tag such as
`20260817-1` for reproducible builds. For stronger reproducibility, pin an
image digest (`@sha256:...`) or use immutable tags in the registry.

### As a Build Stage

The most common use case is to copy configuration files during Docker multi-stage builds:

```dockerfile
FROM ghcr.io/blinklabs-io/cardano-configs:latest AS cardano-configs

FROM your-base-image
# Copy all network configurations
COPY --from=cardano-configs /config/ /opt/cardano/config/
```

### Direct Runtime Usage

You can also run the container directly to copy configuration files to a mounted volume:

```bash
# Copy all network configurations
docker run -v "$(pwd)/configs:/output" ghcr.io/blinklabs-io/cardano-configs:latest /output

# Copy specific network configuration
docker run -v "$(pwd)/configs:/output" ghcr.io/blinklabs-io/cardano-configs:latest /output mainnet
```

## Building

```bash
docker build -t cardano-configs .
```

## Configuration Sources

Configuration files are fetched from:
- Apex Fusion networks: the node configurations in the official
  [Prime testnet](https://github.com/Apex-Fusion/prime-docker),
  [Prime mainnet](https://github.com/Apex-Fusion/prime-mainnet-docker),
  [Vector testnet](https://github.com/Apex-Fusion/vector-docker), and
  [Vector mainnet](https://github.com/Apex-Fusion/vector-mainnet-docker) repositories.
  `./update.sh` refreshes all four networks, including their genesis files and topology.
  Prime uses the node 10.1.4 configuration, Vector testnet uses 10.4.1,
  and Vector mainnet uses 10.5.3.
  The Apex configurations enable metrics listeners; restrict those ports to
  your monitoring network.
  The Vector Conway genesis sets every DRep voting threshold to 0, so DRep
  approval is not required there. The constitutional committee and the SPO
  thresholds are the only checks on governance actions. The files are the
  upstream genesis and match their `ConwayGenesisHash`, so do not edit them.
- Standard networks: https://book.play.dev.cardano.org/environments/
- Musashi: https://book.play.dev.cardano.org/environments-pre/leios/ (enabled by default; set `LEIOS_GO_BRR=false` to skip). The updater applies the existing container metrics binding normalization.
- DijkstraNet: https://book.play.dev.cardano.org/environments-pre/dijkstra/
- Devnet: maintained in this repository under `config/devnet`. It began as a copy of the hydra devnet (https://github.com/cardano-scaling/hydra) but now diverges on protocol version, slot and epoch timing, and Plutus cost models, so `update.sh` no longer re-fetches it.

## Updating Configurations

To update the configuration files, run:

```bash
./update.sh
```

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
