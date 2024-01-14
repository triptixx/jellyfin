ARG UBUNTU_TAG=22.04
ARG JELLYFIN_VER=10.8.13-1
ARG INTEL_CR_VER=23.39.27427.23

FROM loxoo/ubuntu:${UBUNTU_TAG} AS builder

ARG JELLYFIN_VER
ARG INTEL_CR_VER
ARG DEBIAN_FRONTEND="noninteractive"

WORKDIR /output/deb_dpkg

RUN apt-get update; \
    apt-get -y --no-install-recommends --no-install-suggests install \
        wget ca-certificates gnupg jq; \
    wget -qO- https://repo.jellyfin.org/ubuntu/jellyfin_team.gpg.key | gpg --dearmor -o /etc/apt/trusted.gpg.d/jellyfin_team.gpg; \
    echo "deb https://repo.jellyfin.org/\
$( awk -F'=' '/^ID=/{ print $NF }' /etc/os-release ) \
$( awk -F'=' '/^VERSION_CODENAME=/{ print $NF }' /etc/os-release ) main" \
        | tee /etc/apt/sources.list.d/jellyfin.list; \
    apt-get update; \
    chown _apt .; \
    apt-get download $(apt-cache depends --recurse --no-recommends --no-suggests \
        --no-conflicts --no-breaks --no-replaces --no-enhances \
        --no-pre-depends jellyfin-server=${JELLYFIN_VER}  jellyfin-web=${JELLYFIN_VER} jellyfin-ffmpeg6 | grep '^\w'); \
    wget -qO- https://api.github.com/repos/intel/compute-runtime/releases/tags/${INTEL_CR_VER} \
        | jq -r '.body' \
        | sed -rn 's/^wget\s+(.*\.deb)/\1/p' > /list.txt; \
    wget -i /list.txt

COPY *.sh /output/usr/local/bin/
RUN chmod +x /output/usr/local/bin/*.sh

#==============================================================

FROM loxoo/ubuntu:${UBUNTU_TAG}

ARG JELLYFIN_VER
ARG DEBIAN_FRONTEND="noninteractive"
ENV SUID=942 SGID=942

LABEL org.label-schema.name="jellyfin" \
      org.label-schema.description="A Docker image for the Free Software Media System" \
      org.label-schema.url="https://jellyfin.org/" \
      org.label-schema.version=${JELLYFIN_VER}

COPY --from=builder /output/ /

RUN dpkg -i /deb_dpkg/*.deb; \
    rm -rf /deb_dpkg

VOLUME ["/config"]

EXPOSE 8096/TCP

HEALTHCHECK --start-period=10s --timeout=5s \
    CMD wget -qO /dev/null "http://localhost:8096/health"

ENTRYPOINT ["/usr/bin/tini", "--", "/usr/local/bin/entrypoint.sh"]
CMD ["/usr/bin/jellyfin", "--configdir=/config", "--datadir=/config/data", \
    "--cachedir=/config/cache", "--logdir=/config/log", \
    "--webdir=/usr/share/jellyfin/web", "--ffmpeg=/usr/lib/jellyfin-ffmpeg/ffmpeg"]
