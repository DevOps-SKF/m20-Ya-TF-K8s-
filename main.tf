terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
      version = "0.47.0"
    }
    aws = {}
  }
  backend "s3" {
    bucket = "bcommon"
    key    = "tf/m20-ya-k8s.tfstate"
    # export AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY
  }
}  

provider "yandex" {
  token     = var.yandex_token
  cloud_id  = var.yandex_cloud
  folder_id = var.yandex_folder
  zone      = var.yandex_zone
}

###

resource "yandex_vpc_network" "k8s" {
  name = "vpcSKF"
  labels = {
    purpose     = "k8s" 
  }
}

resource "yandex_vpc_subnet" "k8s" {
  name = "k8s-172.19.0"
  v4_cidr_blocks = ["172.19.0.0/24"]
  network_id = yandex_vpc_network.k8s.id
  zone       = var.yandex_zone
  labels = {
    purpose     = "k8s" 
  }
}

resource "yandex_compute_instance" "vmMaster" {
  name        = "vm-master"
  hostname    = "vm-master"
  platform_id = "standard-v2"
  zone        = var.yandex_zone

  resources {
    cores  = 2
    memory = 1
    core_fraction = 5
  }

  boot_disk {
    device_name = "k8s-master"
    initialize_params {
      name = "k8s-master"
      image_id = "fd8vmcue7aajpmeo39kk" # ubuntu-2004-lts-1590073935
      size = 32
      type = "network-hdd"
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.k8s.id
    ip_address = "172.19.0.11"
    nat = true
    ipv6 = false
  }

  scheduling_policy {
    preemptible = true
  }

  metadata = {
    ssh-keys    = "ubuntu:${file("~/.ssh/K8s_pub.pem")}"
  }

  labels = {
    purpose     = "k8s" 
  }
}
