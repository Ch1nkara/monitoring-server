# Monitoring Server

## Dev Container

This repo includes a devcontainer for Terraform and OCI tooling.

- Open the repo in VS Code and use `Dev Containers: Reopen in Container`
- Or run `./devcontainer.sh` from the repo root if you have the Dev Container CLI

Inside the container, Terraform commands should use `-chdir=terraform`.
If you keep OCI config in the repo, create `terraform/.oci/config` from `terraform/.oci/config.template`; the devcontainer symlinks it to `~/.oci/config` automatically.
