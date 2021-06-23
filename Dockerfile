FROM ubuntu:20.04 AS base
# Couldn't get this image any smaller by using debian or debian slim, or other solutions
RUN \
        apt-get update && \
        apt-get clean && \
        apt-get install -f && \
        DEBIAN_FRONTEND=noninteractive \
                apt-get install -y -f \
        		libreoffice \
                libreofficekit-dev \
        && \
        DEBIAN_FRONTEND=noninteractive \
                apt-get install --no-install-recommends -y -f \
        		libvips \
        && \
        apt-get clean && \
        rm -rf /var/lib/apt/lists/

FROM base as builder

RUN \
        apt-get update && \
        apt-get clean && \
        apt-get install -f && \
        DEBIAN_FRONTEND=noninteractive \
                apt-get install --no-install-recommends -y -f \
                libvips-dev \
                curl \
                gcc \
        && \
        apt-get clean && \
        rm -rf /var/lib/apt/lists/

RUN \
        curl -O https://dl.google.com/go/go1.13.6.linux-amd64.tar.gz \
        && tar -C /usr/local -xzf go1.13.6.linux-amd64.tar.gz \
        && rm -rf ./go1.13.6.linux-amd64.tar.gz \
        && export PATH=$PATH:/usr/local/go/bin

ENV PATH="${PATH}:/usr/local/go/bin"

WORKDIR "/app"
COPY *.go *.mod *.sum /app/
RUN go build -tags extralibs


FROM base as worker
WORKDIR "/app"
COPY fonts /app/fonts/
COPY --from=builder /app/preview .

CMD ["./preview"]
STOPSIGNAL SIGINT
