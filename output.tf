output "vm-master_ip" {
    description = "vmMaster public IP address (NAT)"
    value = yandex_compute_instance.vmMaster.network_interface[0].nat_ip_address
}

resource "local_file" "vm-master_ip" {
    content  = yandex_compute_instance.vmMaster.network_interface[0].nat_ip_address
    filename = "vm-master_ip.txt"
}

output "vm-worker_ip" {
    description = "vmWorker public IP address (NAT)"
    value = yandex_compute_instance.vmWorker.network_interface[0].nat_ip_address
}

resource "local_file" "vm-worker_ip" {
    content  = yandex_compute_instance.vmWorker.network_interface[0].nat_ip_address
    filename = "vm-worker_ip.txt"
}
