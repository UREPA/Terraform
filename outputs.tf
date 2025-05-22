output "wordpress_ip" {
  description = "The public IP address of the WordPress VM."
  value       = google_compute_instance.wordpress.network_interface[0].access_config[0].nat_ip
}

output "mysql_root_password" {
  description = "The MySQL root password (stored on the VM at /root/mysql_root_pw.txt)."
  value       = "Check /root/mysql_root_pw.txt on the VM after creation."
}

output "wordpress_db_password" {
  description = "The WordPress DB password (stored on the VM at /root/wp_db_pw.txt)."
  value       = "Check /root/wp_db_pw.txt on the VM after creation."
}
