ARG CI_REGISTRY_IMAGE
ARG DAVFS2_VERSION
FROM ${CI_REGISTRY_IMAGE}/nc-webdav:${DAVFS2_VERSION}
LABEL maintainer="florian.sipp@inserm.fr"

ARG DEBIAN_FRONTEND=noninteractive
ARG CARD
ARG CI_REGISTRY
ARG APP_NAME
ARG APP_VERSION

LABEL app_version=$APP_VERSION

WORKDIR /apps/${APP_NAME}

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install --no-install-recommends -y \ 
    curl unzip libgomp1 libxkbcommon-x11-0 libxcb-keysyms1 && \
    curl -O -L https://github.com/CRNL-Eduwell/Localizer/releases/download/V${APP_VERSION}/Localizer.${APP_VERSION}.linux64.zip && \
    mkdir ./install && \
    unzip -q -d ./install Localizer.${APP_VERSION}.linux64.zip && \
    chmod 755 ./install/Localizer.${APP_VERSION}.linux64/Localizer && \
    rm Localizer.${APP_VERSION}.linux64.zip && \
    apt-get remove -y --purge curl unzip && \
    apt-get autoremove -y --purge && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

ENV APP_SHELL="no"
ENV APP_CMD="/apps/${APP_NAME}/install/Localizer.${APP_VERSION}.linux64/Localizer"
ENV PROCESS_NAME="/apps/${APP_NAME}/install/Localizer.${APP_VERSION}.linux64/Localizer"
ENV DIR_ARRAY=""

HEALTHCHECK --interval=10s --timeout=10s --retries=5 --start-period=30s \
  CMD sh -c "/apps/${APP_NAME}/scripts/process-healthcheck.sh \
  && /apps/${APP_NAME}/scripts/ls-healthcheck.sh /home/${HIP_USER}/nextcloud/"

COPY ./scripts/ scripts/

ENTRYPOINT ["./scripts/docker-entrypoint.sh"]
