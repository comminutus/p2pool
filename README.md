# p2pool
[![AGPL License](https://img.shields.io/badge/license-AGPL-blue.svg)](https://www.gnu.org/licenses/agpl-3.0.html)
[![CI](https://github.com/comminutus/p2pool/actions/workflows/ci.yaml/badge.svg)](https://github.com/comminutus/p2pool/actions/workflows/ci.yaml)
[![GitHub release (latest by date)](https://img.shields.io/github/v/release/comminutus/p2pool)](https://github.com/comminutus/p2pool/releases/latest)


## Description
This is a [p2pool](https://github.com/SChernykh/p2pool) container image built using the binaries distributed by [SChernykh](https://github.com/SChernykh).  The container image runs `p2pool`.

Since the distributed p2pool binary uses dynamically-linked glibc, it uses the [Chainguard glibc-dynamic](https://images.chainguard.dev/directory/image/glibc-dynamic/versions) base image.  This is a distroless container, and as such has very little attack surfaces.  It also has no shell, so it's not possible to execute a shell into the container.

## Getting Started
```
podman pull ghcr.io/comminutus/p2pool
podman run -it --rm ghcr.io/comminutus/p2pool
```

## Usage
Note that the container image does not set any other command line options other than `--data-api` (see "Volumes" below).

For a full list of command line options, run `p2pool --help`.

### Persistent Data
The container's persistent data, including configuration and blockchain data are stored at _/var/lib/p2pool_.

When running the container image with Docker, Kubernetes, OpenShift, etc., mount your volumes at _/var/lib/p2pool_.

### User/Group
Because the container uses Chainguard's image as a base, the `p2pool` process is run as a non-root user. The username and group name is `nonroot`.  The UID and GID are set to _65532_.

### Ports
The container exposes the following ports:
| Port  | Enabled by Default? | Use                                                                                |
| ----- | :-----------------: | ---------------------------------------------------------------------------------- |
| 3333  | Y                    | Stratum server (port used for miners to communicate with p2pool) |
| 37888 | N                    | p2pool-mini side chain peer communications; only used if `--mini` is used on command line |
| 37889 | Y                    | p2pool side chain peer communications; disabled if `--mini` is used on command line |

## Dependencies
| Name                                          |  Version  |
| --------------------------------------------- | --------- |
| [Chainguard glibc-dynamic](https://images.chainguard.dev/directory/image/glibc-dynamic/versions) | latest |
| [p2pool](https://github.com/SChernykh/p2pool) | v4.1 |

## License
The container image portion of this project is licensed under the GNU Affero General Public License v3.0 - see the
[LICENSE](LICENSE) file for details.

The _p2pool_ software binaries included with this container image inherit p2pool's license - see the 
`P2POOL LICENSE` file inside the container or the [LICENSE](https://github.com/SChernykh/p2pool/blob/master/LICENSE) file from p2pool's repository for more details.

The Chainguard _glibc-dynamic_ base container image is licensed under the [Apache 2.0 License](https://github.com/chainguard-images/images/blob/main/LICENSE)
