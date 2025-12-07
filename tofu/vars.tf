data sops_file secrets {
  source_file = "secrets.yaml"
}

locals {
  tenancy_ocid = data.sops_file.secrets.data["tenancy"]
  user_ocid = data.sops_file.secrets.data["user"]
  fingerprint = data.sops_file.secrets.data["fingerprint"]
  region = data.sops_file.secrets.data["region"]
  objectstorage_namespace = data.sops_file.secrets.data["objectstorage_namespace"]
}
