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

provider "aws" {
}

###

resource "yandex_vpc_network" "vpc" {
  name = "vpcSKF"
}
