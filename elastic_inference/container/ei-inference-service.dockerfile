FROM clearlinux/openvino:latest

RUN useradd developer
USER developer

COPY ./apps /apps
COPY ./models /models

RUN pip install -r /apps/requirements.ois.txt --user

ENV MODEL_PATH="/models"
ENV MODEL_NAME="SqueezeNetSSD-5Class"
ENV INPUT_QUEUE_HOST="127.0.0.1"
ENV OUTPUT_BROKER_HOST="127.0.0.1"
ENV INFER_TYPE="face"

# for prometheums metrics
EXPOSE 8000

HEALTHCHECK CMD curl --fail http://localhost:8000/ || exit 1

CMD ["/apps/infer_service.py"]
