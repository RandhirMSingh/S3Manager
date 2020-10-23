FROM python:3.7-alpine

RUN pip install --quiet --no-cache-dir awscli

ADD setCredentials.sh /setCredentials.sh
RUN chmod +x /setCredentials.sh
ENTRYPOINT [ "/setCredentials.sh" ]
