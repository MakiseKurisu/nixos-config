terraform {
  required_providers {
    oci = {
      source = "oracle/oci"
      version = "6.17.0"
    }
    sops = {
      source = "carlpett/sops"
      version = "1.1.1"
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
