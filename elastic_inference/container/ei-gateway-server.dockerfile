FROM clearlinux/python:latest

ARG pip_mirror

RUN useradd developer
USER developer

COPY ./apps /apps
COPY ./spa/dist /dist

RUN pip install ${pip_mirror} -r /apps/requirements.gws.txt --user

ENV STREAM_BROKER_HOST="127.0.0.1"
ENV STREAM_BROKER_PORT="6379"

EXPOSE 5000

HEALTHCHECK CMD curl --fail http://localhost:5000/ || exit 1

CMD ["/apps/gateway_server.py"]
