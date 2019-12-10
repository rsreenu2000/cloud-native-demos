FROM clearlinux/openvino:latest

MAINTAINER ken.lu@intel.com

# create developer user to access /dev/video*
RUN groupadd -g 44 -o developer
RUN useradd -g 44 developer
USER developer

COPY ./apps /apps
RUN pip install -r /apps/requirements.css.txt --user

# Camera device index, set to 0 for /dev/video0 by default
ENV CAMERA_INDEX=0
# Inference type, such as face/people/car
ENV INFER_TYPE="face"
# Customize stream name, otherwise is <ip-address>-<infer type>
ENV STREAM_NAME=""
# FPS for camera stream
ENV CAMERA_FPS=15
# Redis stream queue address
ENV QUEUE_HOST="127.0.0.1"
ENV QUEUE_PORT="6379"
# Prometheus gateway address for metric collection
ENV PROMETHEUS_GATEWAY_HOST=""
ENV PROMETHEUS_GATEWAY_PORT="9091"

CMD ["/apps/camera_stream_service.py"]