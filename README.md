# Prometheus 2.0 \ Grafana 4.6.3 on Kubernetes 1.8.7 (no rbac)


Helm chart for deploying Prometheus and Grafana with full built in Kubernetes pod and infrastructure dashboard

<img src="grafana.png" />

## Prerequisites

* Kubernetes cluster up and running
* Helm
* Kubectl

## Installation

Make sure you have kubernetes up and running and a `kubectl` context pointing to your target cluster. <br/>

```
cd helm

kubectl create namespace monitoring

helm install --name kube-prometheus prometheus -f ../values.yaml --namespace monitoring
helm install --name kube-grafana grafana -f ../values.yaml --namespace monitoring

```

## Make sure everything is running

```
kubectl get pods -n monitoring
```

Once everything is running, you can port-forward to check grafana:

```

kubectl port-forward --namespace=monitoring $(kubectl get pods --namespace=monitoring --selector=app=grafana --output=jsonpath='{.items[*].metadata.name}') 3000:3000

```
