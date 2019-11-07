#!/usr/bin/bash


kubectl create namespace kh
kubectl delete secret dockerhub-etransafe-regcred --namespace kh
kubectl create secret docker-registry dockerhub-etransafe-regcred --namespace kh --docker-server=dockerhub.etransafe.eu:5111 --docker-username=%1 --docker-password=%2 --docker-email=%3
exit
