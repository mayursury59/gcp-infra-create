terraform {
  backend "gcs" {
    bucket = "tf-state-dev0000"
    prefix = "vm"
    
  }
}