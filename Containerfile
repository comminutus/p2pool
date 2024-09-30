########################################################################################################################
# Configuration
########################################################################################################################
# Core Config
ARG p2pool_version=4.1.1

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
ARG base_archive_url="https://github.com/SChernykh/p2pool/releases/download/v${p2pool_version}"

# Copy assets
WORKDIR $build_dir
COPY SChernykh.asc .
COPY LICENSE $license_dir/
COPY download.bash .

# Setup environment variables for script
ENV BASE_ARCHIVE_URL="$base_archive_url"
ENV DIST_DIR="$dist_dir"
ENV P2POOL_VERSION="$p2pool_version"

# Install build packages
RUN apk add --no-cache bash gpg gpg-agent wget          && \
    ./download.bash                                     && \
    cp archive/LICENSE "${license_dir}/P2POOL_LICENSE"


########################################################################################################################
# Final image
########################################################################################################################
FROM cgr.dev/chainguard/glibc-dynamic:latest as final
ARG dist_dir license_dir ports

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
