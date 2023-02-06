# tf-controller-poc
POC to reconcile and operate our resources in AWS via GitOps [Terraform Controller](https://docs.gitops.weave.works/docs/terraform/get-started/) using a local `kind` cluster.

## Installation and Configuration

1. Create a new `kind` cluster
```bash
kind create cluster
```

2. Install Flux Subsystem for Argo from scratch
```bash
kubectl create ns argocd
kubectl -n argocd apply -k "https://github.com/flux-subsystem-argo/flamingo//release?ref=v2.4.12-fl.2-main-d68e6cb8"
```

3. Install Flux
```bash
brew install fluxcd/tap/flux
flux install
```
4. Setup ArgoCD
    Get ArgoCD admin creds
```bash
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo
```
    Forward local port to ArgoCD in background
```
kubectl -n argocd port-forward svc/argocd-server 8080:443 &
```

Now you're able to use ArgoCD Dashboard: `https://localhost:8080/applications`

5. Create a K8s secret with the AWS creds

```
kubectl create ns infra
kubectl -n infra create secret generic aws-credentials --from-literal=AWS_ACCESS_KEY_ID=$POC_ACCESS_KEY_ID --from-literal=AWS_SECRET_ACCESS_KEY=$POC_ACCESS_SECRET_KEY --from-literal=AWS_DEFAULT_REGION="us-east-1"
```
### Prepare the backend

* Start AWS session.
* Run `terraform apply` manually from `./terraform/tfstate-backend`. That will create an S3 bucket, DynamoDB table, and a number of IAM resources required for backend configuration.

## Start GitOpsing

Apply the bootstrap part. That installs tf-controller, required RBAC set, and GitRepository object:

```bash
kubectl apply -f ./argocd-bootstrap-app.yaml
```

Validate this installation (values will be encrypted):

```bash
kubectl -n infra get secret tfstate-backend-outputs -o jsonpath="{.data}"
```
Now the backend is gitopsed.

### Create VPC + EC2 instanse

Apply `ingfa` application:

```bash
kubectl apply -f ./argocd-infra-app.yaml
```

## Open questions

1. Why there are extra GitRepository objects when we have only 1 in the repo (named `tf-controller-poc`)?
    ```
    kubectl get gitrepositories.source.toolkit.fluxcd.io -A
    NAMESPACE   NAME                URL                                                  AGE     READY   STATUS
    infra       bootstrap           https://github.com/masterpointio/tf-controller-poc   3d20h   True    stored artifact for revision 'poc-1/46ca9138db9a958e9251f951f4168a0e21ef396b'
    infra       infra               https://github.com/masterpointio/tf-controller-poc   3d      True    stored artifact for revision 'poc-1/46ca9138db9a958e9251f951f4168a0e21ef396b'
    infra       tf-controller-poc   https://github.com/masterpointio/tf-controller-poc   3d20h   True    stored artifact for revision 'poc-1/46ca9138db9a958e9251f951f4168a0e21ef396b'
    ```

    Same issue could be seen in the [hello-world](https://flux-subsystem-argo.github.io/website/tutorials/terraform/) example - [link to the screenshot](https://flux-subsystem-argo.github.io/website/tutorials/terraform_4.png).

## Tips helpful for debugging

* To check the description of latest installation:

    ```bash
    helm -n flux-system history tf-controller
    ```

* To watch runner logs:

    ```bash
    kubectl -n infra logs -f tfstate-backend-tf-runner
    ```
    Runner name is compiled using the pattern: `<Terraform_Object_Name>-tf-runner`

* Use [Terraform Controller CLI](https://docs.gitops.weave.works/docs/terraform/tfctl/) if you need to manage tf-controller or Terraform resources in a manual mode.