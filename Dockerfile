FROM alpine:latest

RUN apk add miniupnc

COPY root/ /

ENTRYPOINT ["/startup.sh"]
