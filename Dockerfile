FROM alpine:3.12

RUN apk add miniupnpc bash

COPY root/ /

ENTRYPOINT ["/startup.sh"]
