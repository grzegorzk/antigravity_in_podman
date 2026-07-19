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

### Add below function at the end of your .bashrc, replace `/path/to/antigravity_in_podman` with full path where antigravity_in_podman was cloned to

```bash
function agy {
    antigravity_dir=/path/to/antigravity_in_podman
    if [ -z "$1" ]; then
        echo "Call 'agy .' or 'agy /path/to/project'";
    else
        proj_dir=$(cd "$1" && pwd);
        make -C $antigravity_dir run HOST_PATH_TO_PROJECT="$proj_dir" CONTAINER_PATH_TO_MOUNT_PROJECT="$proj_dir";
    fi;
}
```

Once updated:

```bash
source ~/.bashrc
```

You can then call antigravity as you would normally do:

```bash
cd path/to/your/project
agy .
```

### You can also run the container manually

```bash
make run HOST_PATH_TO_PROJECT=/path/to/your/project
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
