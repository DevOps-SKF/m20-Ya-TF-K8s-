terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
      version = "0.47.0"
    }
  }
  
  backend "remote" {
    hostname = "app.terraform.io"
    organization = "AKG"

    workspaces {
      name = "m20-ya-k8s"
    }
  }
}

provider "yandex" {
  token     = var.yandex_token
  cloud_id  = var.yandex_cloud
  folder_id = var.yandex_folder
  zone      = var.yandex_zone
}

###

resource "yandex_vpc_network" "vpc" {
  name = "vpcSKF"
}

