# Kubernetes

## Layout

- `bootstrap/root-app.yaml` - one-time bootstrap application
- `charts/` - Helm charts for the workload
- `argocd/` - Argo CD `Application` pointing at the charts

## Deploy

1. Connect kubectl to the cluster.
2. Apply the bootstrap application once so that argocd monitor argocd/:

   ```sh
   kubectl apply -f kubernetes/bootstrap/root-app.yaml
   ```

3. Wait for Argo CD to sync the child apps.
4. Verify:

   ```sh
   kubectl get application -n argocd
   kubectl get pods -n nginx
   kubectl get svc -n nginx
   ```

## Access

- Open `http://<vm-public-ip>/`
- nginx is exposed through the existing k3s Traefik ingress on port 80

## Delete

- Delete `kubernetes/argocd/nginx-app.yaml` from Git and push.
- Argo CD prunes the `nginx` Application, and the finalizer deletes the managed workload.
