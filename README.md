# cardano-configs

This repository is used to build a container image holding the configuration
files used for a Cardano Node (Haskell) and other ecosystem applications.

## Overview

This project provides Cardano network configuration files in a container image format. It includes configurations for the following networks:
- mainnet
- preprod  
- preview
- sanchonet
- devnet (when `HAIL_HYDRA=true`)

## Usage

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
docker run -v $(pwd)/configs:/output blinklabs/cardano-configs:latest /output

# Copy specific network configuration
docker run -v $(pwd)/configs:/output blinklabs/cardano-configs:latest /output mainnet
```

## Building

```bash
docker build -t cardano-configs .
```

## Configuration Sources

Configuration files are fetched from:
- **Standard networks**: https://book.play.dev.cardano.org/environments/
- **Devnet**: https://github.com/cardano-scaling/hydra (when `HAIL_HYDRA=true`)

## Updating Configurations

To update the configuration files, run:

```bash
./update.sh
```

To include Hydra devnet configurations:

```bash
HAIL_HYDRA=true ./update.sh
```

## Docker Images

The image is available at:
- Docker Hub: `blinklabs/cardano-configs`
- GitHub Container Registry: `ghcr.io/blinklabs-io/cardano-configs`

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.