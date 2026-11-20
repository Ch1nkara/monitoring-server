output "public_ip" {
  description = "Public IP address of the VPS"
  value       = data.oci_core_vnic.primary.public_ip_address
}

output "ssh_command" {
  description = "SSH command to reach the VPS"
  value       = "ssh ubuntu@${data.oci_core_vnic.primary.public_ip_address}"
}

output "argocd_url" {
  description = "Argo CD URL exposed on the VPS"
  value       = "https://${data.oci_core_vnic.primary.public_ip_address}:30443"
}

output "argocd_admin_password_command" {
  description = "Command to read the initial Argo CD admin password"
  value       = "sudo /usr/local/bin/k3s kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d; echo"
}
