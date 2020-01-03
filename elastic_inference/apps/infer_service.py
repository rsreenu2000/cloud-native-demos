#!/usr/bin/python3
"""
Infer service.

It pick up single frame from frame queue and do inference. The result will be
published to stream broker like below.

  +---------------------+    +---------------+    +-----------------------+
  | Frame Queue (redis) | => | Infer Service | => | Stream broker (redis) |
  +---------------------+    +---------------+    +-----------------------+
                                    ||
                                    ##
                    +--------------------------------+
                    | Infer Frame Speed (prometheus) |
                    +--------------------------------+

The infer service can be scaled by kubernete HPA(Horizontal Pod Autoscale)
dynamically according to the metrics like "drop frame speed", "infer frame speed"
"CPU usage" etc.
"""
import os
import sys
import logging
import signal
import socket
import redis
import prometheus_client as prom

# add current path into PYTHONPATH
APP_PATH = os.path.dirname(__file__)
sys.path.append(APP_PATH)

from clcn.appbase import CLCNAppBase                        # pylint: disable=wrong-import-position
from clcn.frame import RedisFrameQueue                      # pylint: disable=wrong-import-position
from clcn.stream import RedisStreamBroker                   # pylint: disable=wrong-import-position
from clcn.nn.inferengine import OpenVinoInferEngineTask     # pylint: disable=wrong-import-position

LOG = logging.getLogger(__name__)

class InferServiceApp(CLCNAppBase):
    """
    Inference service.
    """

    def init(self):
        LOG.info("Host name: %s", socket.gethostname())
        LOG.info("Host ip: %s", socket.gethostbyname(socket.gethostname()))

        self.in_queue_host = self.get_env("INPUT_QUEUE_HOST", "127.0.0.1")
        self.out_broker_host = self.get_env("OUTPUT_BROKER_HOST", "127.0.0.1")

        LOG.info("Input queue host: %s", self.in_queue_host)
        LOG.info("Output broker host: %s", self.out_broker_host)

        self.infer_type = self.get_env("INFER_TYPE", "face")
        self.model_name = self.get_env("MODEL_NAME")

        # MODEL_PATH env got higher priority
        path = self.get_env("MODEL_PATH")
        if path is not None and len(path) != 0:
            self.model_dir = self.get_env("MODEL_PATH")
        else:
            self.model_dir = self.get_env("MODEL_DIR")

        LOG.info("model dir: %s", self.model_dir)
        LOG.info("model name: %s", self.model_name)

        self._guage_infer_fps = prom.Gauge(
            'ei_infer_fps', 'Total infererence FPS')

        self._guage_drop_fps = prom.Gauge(
            'ei_drop_fps', 'Drop frames for infer')

    def run(self):
        in_redis_conn = redis.StrictRedis(self.in_queue_host)
        out_redis_conn = in_redis_conn
        if self.in_queue_host != self.out_broker_host:
            out_redis_conn = redis.StrictRedis(self.out_broker_host)

        input_queue = RedisFrameQueue(in_redis_conn, self.infer_type)
        out_broker = RedisStreamBroker(out_redis_conn)
        out_broker.start_streams_monitor_task()

        infer_task = OpenVinoInferEngineTask(input_queue, out_broker,
                                             self._report_metric_infer_fps,
                                             self._report_metric_drop_fps,
                                             model_dir=self.model_dir,
                                             model_name=self.model_name)

        infer_task.start()
        prom.start_http_server(8000)

    def _report_metric_infer_fps(self, num):
        self._guage_infer_fps.set(num)

    def _report_metric_drop_fps(self, num):
        self._guage_drop_fps.set(num)

def start_app():
    """
    App entry.
    """
    app = InferServiceApp()

    def signal_handler(num, _):
        logging.getLogger().error("signal %d", num)
        app.stop()
        sys.exit(1)

    # setup the signal handler
    signames = ['SIGINT', 'SIGHUP', 'SIGQUIT', 'SIGUSR1']
    for name in signames:
        signal.signal(getattr(signal, name), signal_handler)

    app.run_and_wait_task()

if __name__ == "__main__":
    start_app()
