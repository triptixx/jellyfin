ARG UBUNTU_TAG=24.04
ARG JELLYFIN_VER=10.10.7
ARG INTEL_CR_VER=25.27.34303.5

FROM loxoo/ubuntu:${UBUNTU_TAG}

ARG UBUNTU_TAG
ARG JELLYFIN_VER
ARG INTEL_CR_VER
ARG DEBIAN_FRONTEND="noninteractive"
ENV SUID=942 SGID=942

LABEL org.label-schema.name="jellyfin" \
      org.label-schema.description="A Docker image for the Free Software Media System" \
      org.label-schema.url="https://jellyfin.org/" \
      org.label-schema.version=${JELLYFIN_VER}

COPY *.sh /usr/local/bin/

RUN apt-get update; \
    apt-get -y --no-install-recommends --no-install-suggests install \
        wget ca-certificates gnupg jq; \
    wget -qO- https://repo.jellyfin.org/ubuntu/jellyfin_team.gpg.key | gpg --dearmor -o /etc/apt/trusted.gpg.d/jellyfin_team.gpg; \
    echo "deb https://repo.jellyfin.org/\
$( awk -F'=' '/^ID=/{ print $NF }' /etc/os-release ) \
$( awk -F'=' '/^VERSION_CODENAME=/{ print $NF }' /etc/os-release ) main" \
        | tee /etc/apt/sources.list.d/jellyfin.list; \
    apt-get update; \
    apt-get -y --no-install-recommends --no-install-suggests install \
        jellyfin-server=${JELLYFIN_VER}+ubu${UBUNTU_TAG//.} \
        jellyfin-web=${JELLYFIN_VER}+ubu${UBUNTU_TAG//.} \
        jellyfin-ffmpeg6; \
    mkdir -p /tmp/intel-compute-runtime; \
    wget -qO- https://api.github.com/repos/intel/compute-runtime/releases/tags/${INTEL_CR_VER} \
        | jq -r '.body' \
        | sed -rn 's/^wget\s+(.*\.deb)/\1/p' > /tmp/intel-compute-runtime/list.txt; \
    wget -i /tmp/intel-compute-runtime/list.txt -P /tmp/intel-compute-runtime/; \
    dpkg -i /tmp/intel-compute-runtime/*.deb; \
    chmod +x /usr/local/bin/*.sh; \
    apt-get -y remove gnupg jq; \
    apt-get -y autopurge; \
    apt-get clean; \
    rm -rf /var/lib/apt/lists/* /tmp/*

VOLUME ["/config"]

EXPOSE 8096/TCP

HEALTHCHECK --start-period=10s --timeout=5s \
    CMD wget -qO /dev/null "http://127.0.0.1:8096/health"

ENTRYPOINT ["/usr/bin/tini", "--", "/usr/local/bin/entrypoint.sh"]
CMD ["/usr/bin/jellyfin", "--configdir=/config", "--datadir=/config/data", \
    "--cachedir=/config/cache", "--logdir=/config/log", \
    "--webdir=/usr/share/jellyfin/web", "--ffmpeg=/usr/lib/jellyfin-ffmpeg/ffmpeg"]
