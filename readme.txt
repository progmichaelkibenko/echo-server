Hi, Here is the echo server project
before start to work please be sure that you have installed the following
1. Minikube
2. Kubectl
3. Minikube started
4. Python > 3.6
5. Port 30000 and 5000 is open

Run the initialisation script 'init.sh' by . init.sh-> this script will deploy the kubernetes pods and LoadBalancer service to Minikube

Run the run script by 'run.sh {minikube_ip}' -> this script will run the echo client to check the solution

Note: You can see the minikube ip by "minikube ip" command

Enjoy!!!