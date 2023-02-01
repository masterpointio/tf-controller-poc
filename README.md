# tf-controller-poc
POC to reconcile and operate our resources on AWS via GitOps Terraform Controller

## Installation and Configuration

* Create a new kind cluster
```bash
kind create cluster
```
* Install FSA from scratch
```bash
kubectl create ns argocd
kubectl -n argocd apply -k "https://github.com/flux-subsystem-argo/flamingo//release?ref=v2.4.12-fl.2-main-d68e6cb8"
```

* Install Flux
```bash
brew install fluxcd/tap/flux
flux install
```

* Setup ArgoCD

Get ArgoCD admin creds
```bash
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo
```

Forward local port to ArgoCD in background
```
kubectl -n argocd port-forward svc/argocd-server 8080:443 &
```

* Install tf-controller
```bash
kubectl apply -f bootstrap/tf-controller.yaml
```

* Create a K8s secret with the AWS creds

```
#kubectl create ns dev
kubectl create ns global
kubectl -n global create secret generic aws-credentials --from-literal=AWS_ACCESS_KEY_ID=$POC_ACCESS_KEY_ID --from-literal=AWS_SECRET_ACCESS_KEY=$POC_ACCESS_SECRET_KEY --from-literal=AWS_DEFAULT_REGION="us-east-1"
```
### Prepare backend
* Apply manually `./tf-controller-poc/tfstate-backend/terraform/tfstate-backend`

## Start GitOpsing

Apply `tfstate-backend` application:
```bash
kubectl apply -f tfstate-backend.yaml
```

Validate this installation (values will be encrypted):
```bash
kubectl -n global get secret tfstate-backend-outputs -o jsonpath="{.data}"
```

### TBD
Apply `helloworld-tf` application:
```bash
kubectl apply -f helloworld-tf.yaml
```

kubectl -n global  get secret tfstate-backend-outputs -o jsonpath="{.data}"
Validate this installation:
```bash
kubectl -n dev get secret helloworld-outputs -o jsonpath="{.data.hello_world}" | base64 -d; echo
```

## Links
* [Get Started with the Terraform Controller](https://docs.gitops.weave.works/docs/terraform/get-started/)
* [GitOps Terraform Resources with Argo CD and Flux Subsystem for Argo](https://flux-subsystem-argo.github.io/website/tutorials/terraform/)

## Tips
```bash
helm -n flux-system history tf-controller # contains description of latest installation - helpful for debugging
```