FROM python:3.7-alpine as pythonaws
WORKDIR /root
RUN pip install --quiet --no-cache-dir awscli


FROM swift:5.1 as linuxswift
COPY --from=pythonaws /root .


ADD setCredentials.sh /setCredentials.sh
ADD downlaod_S3Object.swift /downlaod_S3Object.swift
RUN chmod +x /setCredentials.sh
ENTRYPOINT [ "/setCredentials.sh" ]
