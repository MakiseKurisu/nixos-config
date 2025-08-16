terraform {
  required_providers {
    oci = {
      source = "oracle/oci"
    }
    sops = {
      source = "carlpett/sops"
    }
  }
}

provider sops {}

provider oci {
  tenancy_ocid = local.tenancy_ocid
  user_ocid = local.user_ocid
  private_key_path = "~/.oci/oracle-rsa.pem"
  fingerprint = local.fingerprint
  region = local.region
}
