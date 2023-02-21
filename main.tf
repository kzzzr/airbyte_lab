terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">= 0.13"
}

provider "yandex" {
}

resource "yandex_vpc_network" "default_network" {}

resource "yandex_vpc_subnet" "default_subnet" {
  zone           = "ru-central1-b"
  network_id     = yandex_vpc_network.default_network.id
  v4_cidr_blocks = ["10.5.0.0/24"]
}

// Create SA
resource "yandex_iam_service_account" "sa" {
  folder_id = var.folder_id
  name      = "airbyte-storage"
}

// Grant permissions
resource "yandex_resourcemanager_folder_iam_member" "sa-editor" {
  folder_id = var.folder_id
  role      = "storage.editor"
  member    = "serviceAccount:${yandex_iam_service_account.sa.id}"
}

// Create Static Access Keys
resource "yandex_iam_service_account_static_access_key" "sa-static-key" {
  service_account_id = yandex_iam_service_account.sa.id
  description        = "static access key for object storage"
}

// Use keys to create bucket
resource "yandex_storage_bucket" "analytics_engineering_airbyte" {
  access_key    = yandex_iam_service_account_static_access_key.sa-static-key.access_key
  secret_key    = yandex_iam_service_account_static_access_key.sa-static-key.secret_key
  bucket_prefix = "analytics-engineering-airbyte"
  acl           = "public-read"
  max_size      = 32212254720
  force_destroy = true
}

resource "yandex_compute_instance" "airbyte" {
  name        = "airbyte"
  platform_id = "standard-v3"
  zone        = yandex_vpc_subnet.default_subnet.zone

  resources {
    cores         = 4
    memory        = 8
    core_fraction = 100
  }

  boot_disk {
    auto_delete = true
    initialize_params {
      image_id = "fd8linvus5t2ielkr8no" # with Airbyte installed
    #   image_id = "fd80o2eikcn22b229tsa" # Container-optimized image
      size     = 30
      type     = "network-ssd"
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.default_subnet.id
    ipv4      = true
    nat       = true
  }

  scheduling_policy {
    preemptible = true
  }

  metadata = {
    user-data = "${file("cloud-init.yaml")}"
  }
}
