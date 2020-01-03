# Monitoring with [`kube-prometheus`](https://github.com/coreos/kube-prometheus)

## Start monitor

First start the kube-prometheus, just make minor change to export Grafana and Prometheus
service as NodePort for accessing easily. For example,

* grafana -- 31008
* prometheus-k8s -- 31009

` $ kubectl create -f manifests/setup/ `

` $ kubectl create -f manifests/ `

Now start the demo.
Then start the servicemonitor.yaml.

` $ kubectl create -f servicemonitor.yaml `
 
Wait for a while, you will see three new discovered services in http://${NodeIP}:31009/service-discovery.
Now you can try play with prometheus and grafana for the demos reported metrics.

` ei_drop_fps `

` ei_infer_fps `

![Prometheus](../../doc/images/prom.png)

## HPA ( Horizontal Pod Autoscaler )

To try HPA, usually the [`metrics-server`](https://github.com/kubernetes-sigs/metrics-server) needs to be deployed.
But the kube-prometheus stack includes a resource metrics API server, so the metrics-server addon is not necessary.

* For example, start a HPA based on CPU ratio.

` $ kubectl autoscale deployment ei-infer-people-app --cpu-percent=80 --min=1 --max=4 `


