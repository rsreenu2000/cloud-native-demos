# Monitoring with [`kube-prometheus`](https://github.com/coreos/kube-prometheus)

First start the kube-prometheus, just make minor change to export Grafana and Prometheus
service as NodePort for accessing easily.

* grafana -- 31008
* prometheus-k8s -- 31009

Then start the servicemonitor.yaml.

` $ kubectl create -f servicemonitor.yaml `
 


