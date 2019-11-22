# test of new project UPF

# create Persisten volume
kubectl apply -f etransafe.pvc.yaml 
kubectl get pv
kubectl apply -f etransafe.pvc.yaml 
kubectl get pv

# Create container
docker build -t dockerhub.etransafe.eu:5111/manpas/test-of-new-project-upf .
docker push dockerhub.etransafe.eu:5111/manpas/test-of-new-project-upf

# Upload to KH
kubectl apply -f etransafe.flame.yaml 
kubectl delete -f etransafe.flame.yaml 
