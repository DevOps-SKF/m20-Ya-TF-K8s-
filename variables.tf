#variable "yandex_token" {}

### Yandex.Cloud varaiables
variable "yandex_token" { 
  description = "<OAuth>"
  type = string
  sensitive = true
  default = null
}
variable "yandex_cloud" { # <идентификатор облака>
  type = string
  sensitive = true
  default = null
}
variable "yandex_folder" { # <идентификатор каталога>
  type = string
  sensitive = true
  default = null
}
variable "yandex_zone" { # ru-central1-a
  type = string
  default = "ru-central1-a"
}

