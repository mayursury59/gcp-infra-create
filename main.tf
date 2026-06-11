terraform {
  required_providers {
    google = {
        source  = "hashicorp/google"  
    }
  }
}

provider "google" {
  project = var.project_id
}

module "vm" {
    source = "git::https://github.com/mayursury59/terraform-modules.git//VM"

    vm_name = var.vm_name
    machine_type = var.machine_type
    zone = var.zone

    tags = ["dev"]
}
