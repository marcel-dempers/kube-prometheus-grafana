#!/bin/bash

#This script is to test the grafana with its sidecar locally to ensure dashboards can import successfully before deploying onto Kubernetes
#Note: This will just test dashboard import and no metrics will be visible unless a full prometheus stack is running locally

docker run -d --name grafana -p 3000: 3000 grafana/grafana:3.1.1

docker run -it --rm --name grafana-init-sidecar -v $PWD/dashboards:/opt/grafana-import-dashboards -e GRAFANA_API="http://grafana:3000" -e PROMETHEUS_SERVICE="http://prometheus-svc.prometheus:9090" \
--link grafana \
alpine:3.4 sh

#  /bin/sh -c "

apk add --no-cache curl;

sleep 10s
cd /opt/grafana-import-dashboards

echo "writing datasource..."
cat << EOF > k8-datasource.json
{
  "name": "kubernetes",
  "type": "prometheus",
  "url": "$PROMETHEUS_SERVICE",
  "access": "proxy"
}
EOF

echo "importing data sources..."
until $(curl --silent --fail --show-error --output /dev/null $GRAFANA_API/api/datasources); do
    printf '.' ; sleep 1 ;
done ;
for file in *-datasource.json ; do
if [ -e "$file" ] ; then
    echo "importing $file" &&
    curl --silent --fail --show-error \
    --request POST $GRAFANA_API/api/datasources \
    --header "Content-Type: application/json" \
    --data-binary "@$file" ;
    echo "" ;
fi
done ;

file="pods.dashboard.json"
echo "importing $file" &&
(echo '{"dashboard":';cat "$file";echo ',"inputs":[{"name":"DS_KUBERNETES","pluginId":"prometheus","type":"datasource","value":"kubernetes"}]}') | curl --silent --fail --show-error \
--request POST $GRAFANA_API/api/dashboards/import \
--header "Content-Type: application/json" \
--data-binary @-;
echo "" ;

file="resources.dashboard.json"
echo "importing $file" &&
(echo '{"dashboard":';cat "$file";echo ',"inputs":[{"name":"DS_KUBERNETES","pluginId":"prometheus","type":"datasource","value":"kubernetes"}]}') | curl --silent --fail --show-error \
--request POST $GRAFANA_API/api/dashboards/import \
--header "Content-Type: application/json" \
--data-binary @-;
echo "" ;

while true; do
sleep 1m ;
done