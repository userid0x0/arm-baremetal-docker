# arm-baremetal-docker
Minimalistic arm-none-eabi-gcc environment

# Usage
## Linux
### Podman
```bash
podman run --rm --tty --interactive \
  --volume $(realpath ~/):/app
  ghcr.io/userid0x0/arm-baremetal-docker:latest
```
### Docker
```bash
# simple
docker run --rm --tty --interactive \
  --volume $(realpath ~/):/app \
  --env RUN_NON_ROOT_STATDIR=/app \
  ghcr.io/userid0x0/arm-baremetal-docker:latest

# a bit more detailed
docker run --rm --tty --interactive \
  --volume $(realpath ~/):/app \
  --env RUN_NON_ROOT_UID=$(id -u) \
  --env RUN_NON_ROOT_USER=$(id -u -n) \
  --env RUN_NON_ROOT_GID=$(id -g) \
  --env RUN_NON_ROOT_GROUP=$(id -g -n) \
  ghcr.io/userid0x0/arm-baremetal-docker:latest
```

### Painless
```bash
#!/bin/bash

if [ -z ${DOCKER} ]; then
    command -v podman >/dev/null 2>&1 && DOCKER=podman
fi
if [ -z ${DOCKER} ]; then
    command -v docker >/dev/null 2>&1 && DOCKER=docker
fi

${DOCKER} run --rm --tty --interactive \
  --volume $(realpath ~/):/app \
  ghcr.io/userid0x0/arm-baremetal-docker:latest
```

## Windows
```bat
@ECHO OFF
SETLOCAL enableextensions
%~d0

WHERE podman.exe >nul 2>nul
IF NOT DEFINED DOCKER (
  IF %ERRORLEVEL% EQU 0 (SET DOCKER=podman)
)

WHERE docker.exe >nul 2>nul
IF NOT DEFINED DOCKER (
  IF %ERRORLEVEL% EQU 0 (SET DOCKER=docker)
)

IF "%DOCKER%" EQU "podman" (
  FOR /f %%i IN ('podman machine info -f "{{ .Host.MachineState }}"') DO (
    IF "%%i" EQU "Running" (SET PODMAN_STATE=Running)
  )
)
IF "%DOCKER%" EQU "podman" (
  IF "%PODMAN_STATE%" NEQ "Running" (
    echo "Execute: podman machine start"
    podman machine start
  )
)

SET CURDIR=%~dp0

%DOCKER% run --rm --tty --interactive ^
  --volume %CURDIR%:/app ^
  --env RUN_NON_ROOT_STATDIR=/app ^
  ghcr.io/userid0x0/arm-baremetal-docker:latest
```