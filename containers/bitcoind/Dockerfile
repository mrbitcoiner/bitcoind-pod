FROM ubuntu:22.04

RUN printf 'v0.1' > /version

RUN apt update && apt upgrade -y

COPY ./volume/scripts/init.sh /init.sh

ENTRYPOINT [ "/init.sh" ]
