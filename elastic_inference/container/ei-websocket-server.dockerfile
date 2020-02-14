FROM clearlinux/python:latest

ARG pip_mirror

RUN useradd developer
USER developer

COPY ./apps /apps

RUN pip install ${pip_mirror} -r /apps/requirements.wss.txt --user

ENV STREAM_BROKER_REDIS_HOST="127.0.0.1"
ENV STREAM_BROKER_REDIS_PORT="6379"

# for websocket port
EXPOSE 31611

CMD ["/apps/websocket_server.py"]
