# arm-baremetal-docker
Minimalistic arm-none-eabi-gcc environment

# Usage
## Podman
```bash
podman run --rm --tty --interactive -volume $(realpath ~/):/app ghcr.io/userid0x0/arm-baremetal-docker:latest
```
## Docker
```bash
docker run --rm --tty --interactive -volume $(realpath ~/):/app \
  --env RUN_NON_ROOT_UID=$(id -u) \
  --env RUN_NON_ROOT_USER=$(id -u -n) \
  --env RUN_NON_ROOT_GID=$(id -g) \
  --env RUN_NON_ROOT_GROUP=$(id -g -n) \
  ghcr.io/userid0x0/arm-baremetal-docker:latest
```