output "vm-master_ip" {
    description = "vmMaster public IP address (NAT)"
    value = yandex_compute_instance.vmMaster.network_interface[0].nat_ip_address
}

resource "local_file" "vm-master_ip" {
    content  = yandex_compute_instance.vmMaster.network_interface[0].nat_ip_address
    filename = "vm-master_ip.txt"
}
