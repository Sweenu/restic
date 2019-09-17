FROM golang AS builder

COPY . /go/src/github.com/restic/restic/
WORKDIR /go/src/github.com/restic/restic/

RUN go run build.go

FROM alpine as rclone

ADD https://downloads.rclone.org/rclone-current-linux-amd64.zip /
RUN unzip rclone-current-linux-amd64.zip && \
      mv rclone-*-linux-amd64/rclone /usr/bin/rclone && \
      chmod +x /usr/bin/rclone

FROM alpine:latest

RUN apk --no-cache add ca-certificates fuse openssh-client

COPY --from=rclone /usr/bin/rclone /usr/bin/rclone
COPY --from=builder /go/src/github.com/restic/restic/restic /usr/bin/restic

ENTRYPOINT ["/usr/bin/restic"]
