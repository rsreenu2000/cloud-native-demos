#!/bin/bash
#
# Run File Stream Service via direct docker approach
#
curr_dir=$(readlink -f $(dirname "${BASH_SOURCE[0]}"))
top_dir=$(readlink -f ${curr_dir}/../)

DEBUG_MODE=false
VIDEO_FILE="head-pose-face-detection-female-and-male.mp4"
INFER_TYPE="face"
STREAM_NAME=""
QUEUE_HOST="127.0.0.1"
QUEUE_PORT="6379"
PROMETHEUS_GATEWAY_HOST=""
PROMETHEUS_GATEWAY_PORT="9091"
REGISTRY="docker.io/bluewish"

function usage {
    cat << EOM
Usage: $(basename "$0") [OPTION]...

  -d Debug mode that using local source to override container
  -v [video file name] default is head-pose-face-detection-female-and-male.mp4
  -t [face|car|people] infererence type, default is people for body detection
  -s [stream name] default is host-camera_index
  -q <redis output queue host>
  -p <redis output queue port>
  -g <prometheus gateway's address>
  -r <prometheus gateway's port>
  -y <container registry>
EOM
    exit 0
}

function process_args {
    while getopts ":v:t:s:q:p:g:r:y:dh" option; do
        case "${option}" in
            v) VIDEO_FILE=${OPTARG};;
            t) INFER_TYPE=${OPTARG};;
            s) STREAM_NAME=${OPTARG};;
            q) QUEUE_HOST=${OPTARG};;
            p) QUEUE_PORT=${OPTARG};;
            g) PROMETHEUS_GATEWAY_HOST=${OPTARG};;
            r) PROMETHEUS_GATEWAY_PORT=${OPTARG};;
            y) REGISTRY=${OPTARG};;
            d) DEBUG_MODE=true;;
            h) usage;;
        esac
    done
}

process_args "$@"
echo ""
echo "================================"
echo "Debug mode: ${DEBUG_MODE}"
echo "File: ${VIDEO_FILE}"
echo "Infer: ${INFER_TYPE}"
echo "Stream: ${STREAM_NAME}"
echo "Output: ${QUEUE_HOST}"
echo "Registry: ${REGISTRY}"
echo "================================"
echo ""

if [ "$DEBUG_MODE" == true ]; then
    # in dev mode, map local app source into docker image and run this copy
    # instead of default one in container
    ${top_dir}/tools/download-sample-videos.sh
    sudo docker run \
        -v ${top_dir}/apps:/apps \
        -v ${top_dir}/sample-videos:/sample-videos \
        -e VIDEO_FILE=${VIDEO_FILE} \
        -e INFER_TYPE=${INFER_TYPE} \
        -e STREAM_NAME=${STREAM_NAME} \
        -e QUEUE_HOST=${QUEUE_HOST} \
        -e QUEUE_PORT=${QUEUE_PORT} \
        -e PROMETHEUS_GATEWAY_HOST=${PROMETHEUS_GATEWAY_HOST} \
        -e PROMETHEUS_GATEWAY_PORT=${PROMETHEUS_GATEWAY_PORT} \
        --restart on-failure:5 \
        ${REGISTRY}/ei-file-stream-service \
        /apps/file_stream_service.py
else
    sudo docker run \
        -e VIDEO_FILE=${VIDEO_FILE} \
        -e INFER_TYPE=${INFER_TYPE} \
        -e STREAM_NAME=${STREAM_NAME} \
        -e QUEUE_HOST=${QUEUE_HOST} \
        -e QUEUE_PORT=${QUEUE_PORT} \
        -e PROMETHEUS_GATEWAY_HOST=${PROMETHEUS_GATEWAY_HOST} \
        -e PROMETHEUS_GATEWAY_PORT=${PROMETHEUS_GATEWAY_PORT} \
        --restart on-failure:5 \
        ${REGISTRY}/ei-file-stream-service
fi
