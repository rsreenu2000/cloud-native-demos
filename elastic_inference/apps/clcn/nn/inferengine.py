"""
Openvino based inference engine
"""
import logging
import time
import cv2
import numpy as np
from openvino.inference_engine import IEPlugin

from clcn.appbase import CLCNTask
from clcn.stream import StreamInfo
from clcn.nn.nn import NNGeneralDetection

LOG = logging.getLogger(__name__)

class InferEngineTask(CLCNTask):
    """
    Inference task.
    """

    def __init__(self, input_queue, output_broker, report_metric_fps_fn=None):
        CLCNTask.__init__(self)
        self._input_queue = input_queue
        self._output_broker = output_broker
        self._infer_frame_count = 0
        self._infer_time_start = 0
        self._cached_streams = {}
        self._report_metric_fps_fn = report_metric_fps_fn

    def infer(self, frame):
        """
        Infer a frame
        """
        raise NotImplementedError("inheritted class must implement this")

    def execute(self):
        """
        Task entry
        """
        self._infer_time_start = time.time()
        while not self.is_task_stopping:
            now = time.time()
            for key in list(self._cached_streams):
                info = StreamInfo.from_id(key)
                if self._input_queue.is_stream_expired(info):
                    self._output_broker.unregister_stream(info)
                    del self._cached_streams[key]

            msg = self._input_queue.pop()
            if msg is None:
                time.sleep(0.05)
                continue

            info = StreamInfo(msg.name, msg.category, "inferred")
            if info.id not in self._cached_streams.keys():
                self._output_broker.register_stream(info)

            self._cached_streams[info.id] = now

            # decode frame from queue
            image = np.asarray(bytearray(msg.data), dtype="uint8")
            image = cv2.imdecode(image, cv2.IMREAD_COLOR)

            # infer the frame
            result = self.infer(image)

            # encode inferred frame
            _, jpeg = cv2.imencode('.jpg', result)

            # send to broker
            self._output_broker.publish(info, jpeg.tobytes())

            duration = now - self._infer_time_start
            self._infer_frame_count += 1
            if duration > 10:
                LOG.info("[%s] Infer speed: %02f FPS", \
                    info.category, self._infer_frame_count / duration)
                if self._report_metric_fps_fn is not None:
                    self._report_metric_fps_fn(
                        self._infer_frame_count / duration)
                self._infer_time_start = now
                self._infer_frame_count = 0


class OpenVinoInferEngineTask(InferEngineTask):
    """
    Openvino based inference engine
    """

    _DEFAULT_MODEL_DIR = "/models/"
    _DEFAULT_MODLE_NAME = "SqueezeNetSSD-5Class"

    def __init__(self, origin_frame_queue, inferred_frame_queue,
                 report_metric_fps_fn=None,
                 model_dir=_DEFAULT_MODEL_DIR,
                 model_name=_DEFAULT_MODLE_NAME):
        InferEngineTask.__init__(self, origin_frame_queue, \
            inferred_frame_queue, \
            report_metric_fps_fn)
        LOG.info("Model dir: %s", model_dir)
        LOG.info("Model name: %s", model_name)
        self._plugin = self._init_openvino_cpu_plugin()
        self._nn = NNFactory.get_detection(model_dir, model_name)
        self._nn.load()
        self._exec = self._plugin.load(network=self._nn.net)

    @staticmethod
    def _init_openvino_cpu_plugin():
        plugin = IEPlugin(device="CPU")
        plugin.add_cpu_extension("/usr/lib64/libcpu_extension.so")
        return plugin

    def infer(self, frame):
        in_frame = self._nn.process_input(frame)
        res = self._exec.infer(inputs={self._nn.input_blob: in_frame})
        return self._nn.process_output(frame, res)

class NNFactory:
    """
    Factory class for NN detection instance
    """

    @staticmethod
    def get_detection(model_dir, model_name):
        """
        Get NN detection class according to model name
        """
        if model_name.lower() in [
                "person-detection-retail-0013",
                "person-vehicle-bike-detection-crossroad-0078",
                "face-detection-retail-0005",
                "squeezenetssd-5class"]:
            return NNGeneralDetection(model_dir, model_name)

        return None
