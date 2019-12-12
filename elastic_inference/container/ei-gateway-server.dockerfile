FROM clearlinux/python:latest

RUN useradd developer
USER developer

COPY ./apps /apps
COPY ./spa/dist /dist

RUN pip install -r /apps/requirements.gws.txt --user

ENV STREAM_BROKER_HOST="127.0.0.1"
ENV STREAM_BROKER_PORT="6379"

EXPOSE 5000

HEALTHCHECK CMD curl --fail http://localhost:5000/ || exit 1

CMD ["/apps/gateway_server.py"]
