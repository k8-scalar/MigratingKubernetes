The azure.yaml file is to be inserted as a configmap:
```
kubectl create ns conformance
kubectl create configmap game-config --from-file="./azure.json,./azure.yaml" -n conformance
```
The file is passed to e2e test suite via the --cloud-config-file parameter which is only used for Azure

