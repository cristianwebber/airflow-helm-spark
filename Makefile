
full-install: minikube-start deploy-airflow secret-github
	echo "Wait 30 seconds and then run make run-airflow"

minikube-start:
	minikube start

minikube-stop:
	minikube stop

# track changes in cluster and github
argo-deploy:
	kubectl create namespace argocd
	kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

port-argo:
	kubectl port-forward svc/argocd-server -n argocd 8080:443

argo-secret:
	kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo

deploy-airflow:
	kubectl create namespace airflow
	helm install airflow apache-airflow/airflow --values airflow/values.yaml --namespace airflow --debug

show-values-airflow:
	helm show values apache-airflow/airflow > show_values_airflow.yaml

get-values-airflow:
	helm get values airflow -n airflow > actual_values_airflow.yaml

run-airflow:
	kubectl port-forward svc/airflow-webserver 8000:8080 -n airflow

upgrade-airflow:
	helm upgrade --install airflow apache-airflow/airflow -n airflow -f airflow/values.yaml --debug

secret-github:
	kubectl create secret generic airflow-ssh-git-secret --from-file=gitSshKey=/home/crist/.ssh/airflow -n airflow

deploy-spark:
	kubectl create namespace spark
	helm install spark bitnami/spark --namespace spark

show-values-spark:
	helm show values bitnami/spark > show_values_spark.yaml

get-values-spark:
	helm get values spark -n spark > actual_values_spark.yaml

deploy-elasticsearch:
	kubectl create namespace elasticsearch
	helm install elasticsearch elastic/elasticsearch -f elasticsearch/values.yaml -n elasticsearch --debug

deploy-kibana:
	kubectl create namespace kibana
	helm install kibana elastic/kibana -f kibana/values.yaml -n kibana --debug

run-kibana:
	kubectl port-forward deployment/kibana-kibana 5601 -n kibana

repos-add:
	helm repo add elastic https://Helm.elastic.co
	Helm install --name kibana elastic/kibana 
	helm repo add apache-airflow https://airflow.apache.org

	helm repo add bitnami https://charts.bitnami.com/bitnami
	helm install my-release bitnami/spark