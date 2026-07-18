# Antigravity in Podman

Run **Google DeepMind Antigravity CLI** (`agy`) within unprivileged Podman container 

Installed directly from https://antigravity.google

## Why?

 - Extra layer to ensure agent can access / modify / (or damage) what is explicitly exposed

## Requirements

- [Podman](https://podman.io/) (installed and configured)
- GNU Make

## Getting Started

### Build the image

```bash
make build
```

### Run the container

```bash
make run
```

## Configuration

- **`DOCKER`**: Defaults to `podman`.
- **`ARCH_BASE_IMAGE`**: Defaults to `techgk/arch:latest`.

# Thanks

ArchLinux:
* https://archlinux.org/

Podman:
* https://podman.io/

Google:
* https://antigravity.google
