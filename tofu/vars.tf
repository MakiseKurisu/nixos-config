data sops_file secrets {
  source_file = "tofu.yaml"
}

locals {
  tenancy_ocid = data.sops_file.secrets.data["tenancy"]
  user_ocid = data.sops_file.secrets.data["user"]
  fingerprint = data.sops_file.secrets.data["fingerprint"]
  region = data.sops_file.secrets.data["region"]
  objectstorage_namespace = data.sops_file.secrets.data["objectstorage_namespace"]
  amd64_source_id = data.sops_file.secrets.data["amd64_source_id"]
  arm64_source_id = data.sops_file.secrets.data["arm64_source_id"]
}
