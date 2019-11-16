MINIKUBE_IP=$(minikube ip)

echo "The running minikube ip is "${MINIKUBE_IP}

python3 ./echo-client/echo_client.py ${MINIKUBE_IP}