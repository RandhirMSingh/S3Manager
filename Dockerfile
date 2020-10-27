FROM python:3.7-alpine

RUN pip install --quiet --no-cache-dir awscli

FROM swift:latest as builder
WORKDIR /root
COPY . .
RUN swift build -c release

FROM swift:slim
WORKDIR /root
COPY --from=builder /root .
CMD [".build/x86_64-unknown-linux/release/docker-test"]
    
ADD setCredentials.sh /setCredentials.sh
RUN chmod +x /setCredentials.sh
ENTRYPOINT [ "/setCredentials.sh" ]
