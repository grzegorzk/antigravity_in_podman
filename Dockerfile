ARG GROUP_ID=1001
ARG USER_ID=1001

ARG ARCH_BASE_IMAGE

FROM docker.io/${ARCH_BASE_IMAGE} AS x11_arch

RUN pacman -Sy --disable-download-timeout --noconfirm \
    base-devel \
    python \
    tar \
    which

ARG GROUP_ID
ARG USER_ID
ARG USER_NAME

RUN groupadd -g $GROUP_ID $USER_NAME \
    && useradd -u $USER_ID -g $GROUP_ID -m $USER_NAME

USER $USER_NAME

# antigravity adds to .bashrc
RUN cd /tmp \
    && curl -fsSL https://antigravity.google/cli/install.sh | bash

ENTRYPOINT ["/bin/bash", "-cl"]
CMD ["agy"]
