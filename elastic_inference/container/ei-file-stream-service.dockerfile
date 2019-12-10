FROM clearlinux/openvino:latest

MAINTAINER ken.lu@intel.com

RUN useradd developer
USER developer

COPY ./apps /apps
COPY ./sample-videos /sample-videos

RUN pip install -r /apps/requirements.fss.txt --user

ENV VIDEO_FILE="head-pose-face-detection-female-and-male.mp4"
ENV QUEUE_HOST="127.0.0.1"
ENV QUEUE_PORT="6379"
ENV INFER_TYPE="face"
ENV STREAM_NAME=""
# Prometheus gateway address for metric collection
ENV PROMETHEUS_GATEWAY_HOST=""
ENV PROMETHEUS_GATEWAY_PORT="9091"

CMD ["/apps/file_stream_service.py"]
