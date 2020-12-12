### Yandex.Cloud varaiables
variable "yandex_token" { 
  description = "<OAuth>"
  type = string
  sensitive = true
  default = null
}
variable "yandex_keyid" { 
  description = "<идентификатор статического ключа> svcacc"
  type = string
  sensitive = true
  default = null
}
variable "yandex_key" { 
  description = "<секретный ключ> svcacc"
  type = string
  default = null
}

variable "yandex_cloud" { 
  description = "<идентификатор облака>"
  type = string
  default = null
}
variable "yandex_folder" { 
  description = "<идентификатор каталога>"
  type = string
  default = null
}
variable "yandex_zone" { 
  description = "zone (region)"
  type = string
  default = "ru-central1-a"
}
