#adding helm repos
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update

#creating new namespace for monitoring
kubectl create namespace monitoring

#installing helm repos to monitoring namespace
helm install monitoring prometheus-community/kube-prometheus-stack \
  --namespace monitoring

#verifying running pod status in monitoring namespace
kubectl get pods -n monitoring

#Loki and Promtail installation
helm install loki grafana/loki-stack \
  --namespace monitoring \
  --set grafana.enabled=false \
  --set prometheus.enabled=false \
  --set promtail.enabled=true

#verifying running pod status
kubectl get pods -n monitoring | grep loki

#learning first secret password for grafana interface login
kubectl get secret -n monitoring monitoring-grafana -o jsonpath="{.data.admin-password}" | base64 -d ; echo

#port forwarding and launching grafana interface on web browser
kubectl port-forward svc/monitoring-grafana -n monitoring 3000:80
#user: admin  password: secret key that we learned above
