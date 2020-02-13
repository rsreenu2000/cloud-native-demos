FROM clearlinux/openvino:latest

ARG pip_mirror

RUN useradd developer
USER developer

COPY ./apps /apps
COPY ./sample-videos /sample-videos

RUN pip install ${pip_mirror} -r /apps/requirements.fss.txt --user

ENV VIDEO_FILE="head-pose-face-detection-female-and-male.mp4"
ENV QUEUE_HOST="127.0.0.1"
ENV QUEUE_PORT="6379"
ENV INFER_TYPE="face"
ENV STREAM_NAME=""

CMD ["/apps/file_stream_service.py"]
