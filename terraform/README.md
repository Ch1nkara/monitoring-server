# Terraform

This creates:

- OCI VCN, subnet, route table, and security list
- One Ampere free-tier VPS
- `k3s` Kubernetes on first boot
- Argo CD installed into the cluster

## Prerequisites

- Terraform 1.6+
- OCI CLI config or environment credentials
- An OCI compartment OCID
- One standard SSH public key for VM login

The OCI provider will read `~/.oci/config` by default.

## Usage

1. Copy `terraform.tfvars.example` to `terraform.tfvars`.
2. Copy `terraform/.oci/config.template` to `terraform/.oci/config` and fill in your OCI user OCID, tenancy OCID, fingerprint, and region.
3. Create the OCI API key pair:

   ```sh
   openssl genrsa -out terraform/.oci/oci_api_key.pem 2048
   openssl rsa -pubout -in terraform/.oci/oci_api_key.pem -out terraform/.oci/oci_api_key_public.pem
   chmod 600 terraform/.oci/oci_api_key.pem
   ```

4. Upload `terraform/.oci/oci_api_key_public.pem` to OCI and copy the fingerprint into `terraform/.oci/config`.
5. Derive the VM SSH public key from the same OCI API private key:

   ```sh
   ssh-keygen -y -f terraform/.oci/oci_api_key.pem > terraform/.oci/oci_api_key_ssh.pub
   ```

6. Fill in your compartment OCID and SSH public key path in `terraform.tfvars`.
7. If you are not using the devcontainer, symlink `terraform/.oci/config` to `~/.oci/config`.
8. Run `terraform -chdir=terraform init`.
9. Run `terraform -chdir=terraform apply`.

The devcontainer mounts `terraform/.oci` into `/root/.oci`, so the OCI config and keys are read from the standard OCI path.

## Access

- Argo CD: `https://<public-ip>:30443`
- SSH: `ssh ubuntu@<public-ip>`
