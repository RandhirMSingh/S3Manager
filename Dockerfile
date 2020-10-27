FROM python:3.7-alpine

RUN pip install --quiet --no-cache-dir awscli
RUN pip install gcc7
RUN pip install swift
    
ADD setCredentials.sh /setCredentials.sh
RUN chmod +x /setCredentials.sh
ENTRYPOINT [ "/setCredentials.sh" ]
