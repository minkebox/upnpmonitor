FROM alpine:latest

RUN apk add miniupnpc bash

COPY root/ /

ENTRYPOINT ["/startup.sh"]
