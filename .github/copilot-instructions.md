# Workspace-specific instructions for Copilot

- Use Terraform best practices for GCP.
- Prioritize lowest-cost resources (e2-micro, preemptible if possible).
- Use Google provider.
- Output public IP and admin password.
- Use minimal persistent disk.
- No managed database (use local MySQL).
- No load balancer.
- Use firewall rules for HTTP/HTTPS only.
- All code and infra in this folder.
