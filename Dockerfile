FROM docker.io/library/debian:bookworm-slim AS builder
# see also https://github.com/creemama/docker-run-non-root

ARG SUEXEC_REV=dddd1567b7c76365e1e0aac561287975020a8fad

# Install su-exec (https://github.com/ncopa/su-exec/commit/dddd1567b7c76365e1e0aac561287975020a8fad).
ADD https://github.com/ncopa/su-exec/archive/${SUEXEC_REV}.zip su-exec.zip
RUN apt update \
    && apt install --no-install-recommends -y \
        tcc \
        libc-dev \
        make \
        unzip \
    && rm -rf /var/lib/{apt,dpkg,cache,log}/ \
    && unzip su-exec.zip \
    && make -C su-exec-${SUEXEC_REV} CC=tcc \
    && mv su-exec-${SUEXEC_REV}/su-exec /usr/local/bin

# Install run-non-root.
ADD https://raw.githubusercontent.com/creemama/run-non-root/v1.5.1/run-non-root.sh /usr/local/bin/run-non-root
RUN chmod +rx /usr/local/bin/run-non-root

ADD https://raw.githubusercontent.com/userid0x0/run-non-root-wrapper/78825717dafb6f473bc4087312c0f851d5900e2d/run-non-root-wrapper.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +rx /usr/local/bin/docker-entrypoint.sh

FROM docker.io/library/debian:bookworm-slim

COPY --from=builder \
    /usr/local/bin/docker-entrypoint.sh \
    /usr/local/bin/run-non-root \
    /usr/local/bin/su-exec \
    /usr/local/bin

RUN apt update \
    && apt install -y \
        curl \
        make \
        tini \
        xz-utils \
    && rm -rf /var/lib/{apt,dpkg,cache,log}/

RUN curl -s -L  "https://developer.arm.com/-/media/Files/downloads/gnu/12.2.rel1/binrel/arm-gnu-toolchain-12.2.rel1-x86_64-arm-none-eabi.tar.xz" \
        | tar -C /opt -xJ \
    && find /opt -type d -name "arm-gnu-toolchain-*" -exec ln -s \{\} /opt/arm-none-eabi-gcc \;
ENV PATH="/opt/arm-none-eabi-gcc/bin:${PATH}"

VOLUME "/app"
WORKDIR "/app"

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
CMD ["/bin/bash"]
