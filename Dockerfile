FROM tools.standardbank.co.za:8093/tpsdevops/golang-basic:latest AS builder

RUN mkdir -p /usr/local/go/src/sbsa.com/tps/releasenotes

ADD . /usr/local/go/src/sbsa.com/tps/releasenotes

WORKDIR /usr/local/go/src/sbsa.com/tps/releasenotes/cmd

RUN go get ./...

RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -a -tags netgo -ldflags '-w -extldflags "-static"' -o cmd cmd.go

FROM tools.standardbank.co.za:8093/tpsdevops/alpine:3.12.1

WORKDIR /root/

RUN apk update && apk add ca-certificates && rm -rf /var/cache/apk/*

ADD certs /usr/local/share/ca-certificates

RUN update-ca-certificates

RUN apk add -U tzdata

RUN cp /usr/share/zoneinfo/Africa/Johannesburg /etc/localtime

RUN date

RUN apk add -U git

RUN git config --global user.email "TPSITDevOps@mail.standardbank.com"

RUN git config --global user.name "TPS DevOps"

# ADD bin releasenotes

ENV HOME /releasenotes

RUN mkdir -p /releasenotes/output/

RUN mkdir -p /releasenotes/workdir/

COPY --from=builder /usr/local/go/src/sbsa.com/tps/releasenotes/cmd/cmd /releasenotes/cmd

COPY --from=builder /usr/local/go/src/sbsa.com/tps/releasenotes/cmd/data /releasenotes/data/

WORKDIR /releasenotes

EXPOSE 8107

CMD ["/releasenotes/cmd"]
