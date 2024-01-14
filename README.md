[hub]: https://hub.docker.com/r/loxoo/jellyfin
[git]: https://github.com/triptixx/jellyfin/tree/main
[actions]: https://github.com/triptixx/jellyfin/actions/workflows/main.yml

# [loxoo/jellyfin][hub]
[![Git Commit](https://img.shields.io/github/last-commit/triptixx/jellyfin/main)][git]
[![Build Status](https://github.com/triptixx/jellyfin/actions/workflows/main.yml/badge.svg?branch=main)][actions]
[![Latest Version](https://img.shields.io/docker/v/loxoo/jellyfin/latest)][hub]
[![Size](https://img.shields.io/docker/image-size/loxoo/jellyfin/latest)][hub]
[![Docker Stars](https://img.shields.io/docker/stars/loxoo/jellyfin.svg)][hub]
[![Docker Pulls](https://img.shields.io/docker/pulls/loxoo/jellyfin.svg)][hub]

## Usage

```shell
docker run -d \
    --name=srvjellyfin \
    --restart=unless-stopped \
    --hostname=srvjellyfin \
    -p 8096:8096 \
    -v $PWD/config:/config \
    loxoo/jellyfin
```

## Environment

- `$SUID`                          - User ID to run as. _default: `942`_
- `$SGID`                          - Group ID to run as. _default: `942`_
- `$TZ`                            - Timezone. _optional_

## Volume

- `/config`                        - A path for storing jellyfin global config.

## Network

- `8096/tcp`                       - The port that jellyfin should listen for web connections on.
