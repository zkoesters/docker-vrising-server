FROM diyagi/steamcmd-wine:root-noble AS base-steamcmd-wine

ARG DEBIAN_FRONTEND="noninteractive"
ARG JO_VERSION="1.9-1"
ARG JQ_VERSION="1.7.1-3build1"
ARG TZDATA_VERSION="2025b-0ubuntu0.24.04.1"
ARG VIM_VERSION="2:9.1.0016-1ubuntu7.8"
ARG GORCON_VERSION="0.10.3"
ARG GORCON_CHECKSUM="6962a641ebf9a5957bd0cda1b8acf3e34a23686ae709f6c6a14ac3898521a5cc"
ARG SUPERCRONIC_VERSION="0.2.33"
ARG SUPERCRONIC_CHECKSUM="feefa310da569c81b99e1027b86b27b51e6ee9ab647747b49099645120cfc671"

ADD --checksum=sha256:${GORCON_CHECKSUM}  \
    https://github.com/gorcon/rcon-cli/releases/download/v${GORCON_VERSION}/rcon-${GORCON_VERSION}-amd64_linux.tar.gz \
    /tmp/rconcli.tar.gz

ADD --checksum=sha256:${SUPERCRONIC_CHECKSUM} \
    https://github.com/aptible/supercronic/releases/download/v${SUPERCRONIC_VERSION}/supercronic-linux-amd64 \
    /usr/local/bin/supercronic

RUN apt-get update -y && \
    apt-get install -y --no-install-recommends \
        jo=${JO_VERSION} \
        jq=${JQ_VERSION} \
        tzdata=${TZDATA_VERSION} \
        vim=${VIM_VERSION} && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    tar -xf /tmp/rconcli.tar.gz \
        --strip-components=1 \
        --transform='s/rcon/rcon-cli/' \
        -C /usr/bin/ \
        rcon-${GORCON_VERSION}-amd64_linux/rcon && \
    rm /tmp/rconcli.tar.gz && \
    chmod +x /usr/local/bin/supercronic

ENV STEAMAPP=vrising
ENV STEAMAPPDIR="/${STEAMAPP}"
ENV STEAMAPPSERVER="${STEAMAPPDIR}/server"
ENV STEAMAPPDATA="${STEAMAPPDIR}/data"
ENV LOGSDIR="${STEAMAPPDATA}/logs"
ENV SCRIPTSDIR="${STEAMAPPDIR}/scripts"
ENV ANNOUNCEDIR="${STEAMAPPDIR}/announce"

ENV PUID=1000 \
    PGID=1000 \
    COMPILE_HOST_SETTINGS=false \
    COMPILE_GAME_SETTINGS=false \
    UPDATE_ON_BOOT=true \
    AUTO_UPDATE_ENABLED=false \
    AUTO_UPDATE_CRON_EXPRESSION="0 * * * *" \
    AUTO_UPDATE_WARN_MINUTES="30,15,10,5,3,2,1" \
    AUTO_UPDATE_WARN_MESSAGE="Server will restart in ~{t} min. Reason: Scheduled Update" \
    AUTO_REBOOT_ENABLED=false \
    AUTO_REBOOT_CRON_EXPRESSION="0 0 * * *" \
    AUTO_REBOOT_WARN_MINUTES="15,10,5,3,2,1" \
    AUTO_REBOOT_WARN_MESSAGE="Server will restart in ~{t} min. Reason: Scheduled Restart" \
    AUTO_ANNOUNCE_ENABLED=false \
    AUTO_ANNOUNCE_CRON_EXPRESSION="*/10 * * * *" \
    DISCORD_SUPPRESS_NOTIFICATIONS="" \
    DISCORD_WEBHOOK_URL="" \
    DISCORD_CONNECT_TIMEOUT=30 \
    DISCORD_MAX_TIMEOUT=30 \
    DISCORD_PRE_START_MESSAGE="Server has been started!" \
    DISCORD_PRE_START_MESSAGE_URL="" \
    DISCORD_PRE_START_MESSAGE_ENABLED=true \
    DISCORD_PRE_SHUTDOWN_MESSAGE="Server is shutting down..." \
    DISCORD_PRE_SHUTDOWN_MESSAGE_URL="" \
    DISCORD_PRE_SHUTDOWN_MESSAGE_ENABLED=true \
    DISCORD_POST_SHUTDOWN_MESSAGE="Server has been stopped!" \
    DISCORD_POST_SHUTDOWN_MESSAGE_URL="" \
    DISCORD_POST_SHUTDOWN_MESSAGE_ENABLED=true


# Build directories
RUN mkdir ${STEAMAPPDIR} ${STEAMAPPSERVER} ${STEAMAPPDATA} ${SCRIPTSDIR} ${ANNOUNCEDIR}

COPY ./scripts ${SCRIPTSDIR}

WORKDIR ${SCRIPTSDIR}

RUN touch ${SCRIPTSDIR}/rcon.yaml \
    && chown steam:steam -R ${STEAMAPPDIR} \
    && chmod +x ${SCRIPTSDIR}/*.sh \
    && mv ${SCRIPTSDIR}/testannounce.sh /usr/local/bin/testannounce \
    && mkdir /tmp/.X11-unix \
    && chmod 1777 /tmp/.X11-unix \
    && chown root /tmp/.X11-unix

CMD ["/vrising/scripts/init.sh"]