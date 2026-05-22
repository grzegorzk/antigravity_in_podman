ARG GROUP_ID=1001
ARG USER_ID=1001

ARG ARCH_BASE_IMAGE

FROM docker.io/${ARCH_BASE_IMAGE} AS x11_arch

RUN pacman -Sy --disable-download-timeout --noconfirm \
        archlinux-keyring \
    && pacman-key --refresh-keys \
    && pacman -Sy --disable-download-timeout --noconfirm \
        gemini-cli \
        git \
    && /bin/bash /root/skim.sh

ARG GROUP_ID
ARG USER_ID
ARG USER_NAME

RUN groupadd -g $GROUP_ID $USER_NAME \
    && useradd -u $USER_ID -g $GROUP_ID -m $USER_NAME

RUN sed -i -- 's/#[ ]*\(%wheel[ ]*ALL[ ]*=[ ]*([ ]*ALL[ ]*:[ ]*ALL[ ]*)[ ]*NOPASSWD[ ]*:[ ]*ALL\)$/\1/gw /tmp/sed.done' /etc/sudoers \
    && [ -z "$(cat /tmp/sed.done | wc -l)" ] && echo "Failed to enable sudo for wheel group" && exit 1 \
    || echo "Enabled sudo for wheel group" && rm /tmp/sed.done

USER $USER_NAME

RUN cd /tmp \
    && git clone https://aur.archlinux.org/trizen.git \
    && cd trizen \
    && makepkg -si --noconfirm \
    && cd / \
    && rm -r /tmp/trizen

RUN mkdir -p ~/.gemini \
    && git clone https://github.com/JuliusBrussee/caveman /tmp/caveman \
    && echo '{"/tmp/caveman": "TRUST_FOLDER"}' > ~/.gemini/trustedFolders.json \
    && gemini extensions install /tmp/caveman --consent \
    && sed -i 's/^tools: Read, Edit, Write, Grep, Glob$/tools: [read_file, replace, write_file, grep_search, glob]/' \
        /tmp/caveman/agents/cavecrew-builder.md \
    && sed -i 's/^tools: Read, Grep, Glob, Bash$/tools: [read_file, grep_search, glob, run_shell_command]/' \
        /tmp/caveman/agents/cavecrew-investigator.md \
    && sed -i 's/^tools: Read, Grep, Bash$/tools: [read_file, grep_search, run_shell_command]/' \
        /tmp/caveman/agents/cavecrew-reviewer.md \
    && sed -i '/^---$/d' ~/.gemini/extensions/caveman/commands/caveman-init.toml

ENTRYPOINT ["gemini"]
CMD []
