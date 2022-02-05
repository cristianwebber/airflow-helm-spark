

argo-deploy:
	kubectl create namespace argocd
	kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

port-argo:
	kubectl port-forward svc/argocd-server -n argocd 8080:443

argo-secret:
	kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo

deploy-airflow:
	kubectl create namespace airflow
	helm install airflow apache-airflow/airflow --namespace airflow

airflow:
	kubectl port-forward svc/airflow-webserver 8000:8080 -n airflow

upgrade-airflow:
	helm upgrade --install airflow apache-airflow/airflow -n airflow -f values.yaml --debug