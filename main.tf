terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">= 0.13"

    backend "s3" {
      endpoint   = "storage.yandexcloud.net"
      bucket     = "galtsev001-bucket"
      region     = "ru-central1-a"
      key        = "terraform.tfstate"
      access_key = "YCAJEZnBZZln4QivWtiJebkXG"
      secret_key = "YCMllCTrSURfhIb_bieWxW-ymo4yuLq4fAWEmwo1"

      skip_region_validation      = true
      skip_credentials_validation = true
  }
}

provider "yandex" {
  token     = "AQAAAAACi01KAATuwejtKPJgT0QEqrZpbORoEi4"
  cloud_id  = "b1g57d4rv7a3m4dmuhro"
  folder_id = "b1geodooefjvhq6dtnii"
  zone      = "ru-central1-a"
}

resource "yandex_vpc_network" "kube_network" {}

resource "yandex_vpc_subnet" "public" {
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.kube_network.id
  v4_cidr_blocks = ["192.168.10.0/24"]
  name               = "public"
}

resource "yandex_compute_instance" "master" { 
    name               = "master"
    service_account_id = "${yandex_iam_service_account.terraform-stage.id}"
      platform_id = "standard-v2"
      resources {
        memory = 4
        cores  = 2
        core_fraction = 20
      }
      boot_disk {
        mode = "READ_WRITE"
        initialize_params {
        image_id = "fd8kdq6d0p8sij7h5qe3"
        size = 50
        }
      }
      network_interface {
        subnet_id = "${yandex_vpc_subnet.public.id}"
        nat = "true"
        ip_address="192.168.10.20"
      }
        metadata = {
            user-data = "${file("./meta.yml")}"
      }
}

resource "yandex_compute_instance" "node_1" {
    name               = "worker1"
    service_account_id = "${yandex_iam_service_account.terraform-stage.id}"
      platform_id = "standard-v2"
      resources {
        memory = 4
        cores  = 2
        core_fraction = 5
      }
      boot_disk {
        mode = "READ_WRITE"
        initialize_params {
        image_id = "fd8kdq6d0p8sij7h5qe3"
        size = 50
        }
      }
      network_interface {
        subnet_id = "${yandex_vpc_subnet.public.id}"
        nat = "true"
        ip_address="192.168.10.21"
      }
        metadata = {
            user-data = "${file("./meta.yml")}"
      }


}

resource "yandex_compute_instance" "node_2" {
    name               = "worker2"
    service_account_id = "${yandex_iam_service_account.terraform-stage.id}"
      platform_id = "standard-v2"
      resources {
        memory = 4
        cores  = 2
        core_fraction = 5
      }
      boot_disk {
        mode = "READ_WRITE"
        initialize_params {
        image_id = "fd8kdq6d0p8sij7h5qe3"
        size = 50
        }
      }
      network_interface {
        subnet_id = "${yandex_vpc_subnet.public.id}"
        nat = "true"
        ip_address="192.168.10.22"
      }
        metadata = {
            user-data = "${file("./meta.yml")}"
      }
}


resource "yandex_iam_service_account" "terraform-stage" {
  name        = "terraform-stage"
  description = "service account to manage IG"

}

output "ansible_inventory" {
  value = templatefile("./templates/inventory.yml.tpl", {
    master = "${yandex_compute_instance.master.network_interface.0.nat_ip_address}"
    node_1 = "${yandex_compute_instance.node_1.network_interface.0.nat_ip_address}"
    node_2 = "${yandex_compute_instance.node_2.network_interface.0.nat_ip_address}"
    user = "galtsev"
  })
}


