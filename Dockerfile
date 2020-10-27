FROM ubuntu:latest as pythonaws
COPY --from=swift:5.1 . .
COPY --from=python:3.7-alpine . .
COPY --from=curlimages/curl:latest . .
RUN pip install --quiet --no-cache-dir awscli
//RUN pip install curl
RUN swift -version
#RUN aws -version

ADD downlaod_S3Object.swift /downlaod_S3Object.swift
RUN chmod +x /downlaod_S3Object.swift
ADD setCredentials.sh /setCredentials.sh
RUN chmod +x /setCredentials.sh
ENTRYPOINT [ "/setCredentials.sh" ]
