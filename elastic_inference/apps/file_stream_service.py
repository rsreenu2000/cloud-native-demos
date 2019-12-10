#!/usr/bin/python3
"""
File Stream Service.

It collect the frames from video file and send to redis based frame queue after
compression.
"""
import logging
import signal
import os
import sys
import queue
import socket
import redis
import prometheus_client as prom

APP_PATH = os.path.dirname(__file__)
sys.path.append(APP_PATH)

from clcn.video import VideoFileTask            # pylint: disable=wrong-import-position
from clcn.appbase import CLCNAppBase            # pylint: disable=wrong-import-position
from clcn.frame import RedisFrameQueue, FrameQueueProduceTask   # pylint: disable=wrong-import-position
from clcn.stream import StreamInfo              # pylint: disable=wrong-import-position

LOG = logging.getLogger(__name__)

class VideoFileaaS(CLCNAppBase):
    """
    Video File Service to feed frame from existing video file.
    """

    def init(self):
        self._redis_host = self.get_env("QUEUE_HOST", "127.0.0.1")
        self._redis_port = int(self.get_env("QUEUE_PORT", "6379"))
        self._category = self.get_env("INFER_TYPE", "face")
        self._video_file_path = self.get_env("VIDEO_FILE")
        self._video_fps = int(self.get_env("VIDEO_FPS", "30"))
        self._stream_name = self.get_env("STREAM_NAME", "")
        if len(self._stream_name) == 0:
            self._stream_name = "%s-%s" % (
                socket.gethostbyname(socket.gethostname()),
                os.path.basename(self._video_file_path))
        self._stream_info = StreamInfo(self._stream_name, self._category)

        self._prometheus_gateway_host = self.get_env(
            "PROMETHEUS_GATEWAY_HOST", None)
        self._prometheus_gateway_port = self.get_env(
            "PROMETHEUS_GATEWAY_PORT", "9091")
        self._prometheus_registry = prom.CollectorRegistry()
        self._metric_gauge_drop_frames = prom.Gauge(
            'ei_drop_frames',
            'Drop frames for infer',
            registry=self._prometheus_registry)

    def run(self):
        redis_conn = redis.StrictRedis(self._redis_host, self._redis_port)
        out_queue = RedisFrameQueue(redis_conn, self._category)
        out_queue.report_metric_drop_frames_fn = \
            self._report_metric_drop_frame_to_prometheus

        frame_queue = queue.Queue(10)
        video_task = VideoFileTask(frame_queue,
                                   filename=self._video_file_path,
                                   fps=self._video_fps)

        info = StreamInfo(self._stream_name, self._category)
        publisher_task = FrameQueueProduceTask(info, frame_queue, out_queue)

        video_task.start()
        publisher_task.start()

    def _report_metric_drop_frame_to_prometheus(self, num):
        if self._prometheus_gateway_host is None or \
            len(self._prometheus_gateway_host) == 0:
            return
        LOG.info("Publish dropped frame to prometheus: %d", num)
        self._metric_gauge_drop_frames.set(num)
        prom.push_to_gateway(
            self._prometheus_gateway_host + ":" + self._prometheus_gateway_port,
            job=self._stream_info.id,
            registry=self._prometheus_registry)

def start_app():
    """
    App entry.
    """
    app = VideoFileaaS()

    def signal_handler(num, _):
        LOG.error("signal %d", num)
        app.stop()
        sys.exit(1)

    # setup the signal handler
    signames = ['SIGINT', 'SIGHUP', 'SIGQUIT', 'SIGUSR1']
    for name in signames:
        signal.signal(getattr(signal, name), signal_handler)

    app.run_and_wait_task()

if __name__ == "__main__":
    start_app()
