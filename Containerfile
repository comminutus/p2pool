########################################################################################################################
# Configuration
########################################################################################################################
# Core Config
ARG p2pool_version=4.1

# Ports:
# 3333: Stratum server (port used for miners to communicate with p2pool)
# 37888: p2pool-mini side chain peer communications
# 37889: p2pool side chain peer communications
ARG ports="3333 37888 37889"

# Defaults
ARG build_dir=/tmp/build
ARG license_dir=$build_dir/licenses
ARG dist_dir=$build_dir/dist


########################################################################################################################
# Build Image
########################################################################################################################
FROM cgr.dev/chainguard/wolfi-base:latest as build
ARG build_dir license_dir dist_dir p2pool_version
ARG base_archive_url=https://github.com/SChernykh/p2pool/releases/download/v${p2pool_version}

# Options for tools
ARG build_packages='gpg gpg-agent wget'
ARG gpg='gpg --batch'
ARG wget='wget -q'

# Copy assets
WORKDIR $build_dir
COPY SChernykh.asc .
COPY LICENSE $license_dir/

# Install build packages
RUN apk add $build_packages

# Download SHA-256 hashes and signatures; verify signatures
RUN $gpg --import SChernykh.asc
RUN $wget $base_archive_url/sha256sums.txt.asc
RUN $gpg --verify sha256sums.txt.asc

# Setup metadata about archive
RUN set -ex                                                         && \
  platform="$(uname -a | awk '{print tolower($1)}')"                && \
  echo "$platform" > platform.txt                                   && \
  arch="$(uname -m | sed 's/x86_64/x64/g')"                         && \
  echo "$arch" > arch.txt                                           && \
  archive="p2pool-v${p2pool_version}-$platform-$arch.tar.gz"        && \
  echo "$archive" > archive.txt

# Download archive
RUN $wget "$base_archive_url/$(cat archive.txt)"

# Verify archive
RUN echo "$(cat sha256sums.txt.asc | grep $(cat archive.txt) -A 2 | sed -n '3p' | sed 's/\r$//' | awk '{print tolower($2)}') $(cat archive.txt)" | sha256sum -c

# Extract archive
RUN mkdir -p "$dist_dir" archive
RUN tar -x --strip-components 1 -C archive -f "$(cat archive.txt)"
RUN cp archive/p2pool "$dist_dir"

# Copy p2pool license file
RUN cp archive/LICENSE $license_dir/P2POOL_LICENSE


########################################################################################################################
# Final image
########################################################################################################################
FROM cgr.dev/chainguard/glibc-dynamic as final
ARG dist_dir ports

# Install binaries
COPY --from=build $dist_dir /usr/local/bin
COPY --from=build $license_dir /usr/local/share/licenses/p2pool

# Setup a volume for persistent data
VOLUME /var/lib/p2pool

# Expose ports
EXPOSE $ports

# Set working directory to /home/nonroot since p2pool will write the peer list to the working directory
WORKDIR /home/nonroot

# Run entrypoint
ENTRYPOINT ["/usr/local/bin/p2pool", "--data-api", "/var/lib/p2pool"]
