terraform {
  backend "s3" {
    endpoints                   = { s3 = "https://s3.fr-par.scw.cloud" }
    key                         = "repo-config"
    region                      = "fr-par"
    skip_credentials_validation = true
    skip_region_validation      = true
    skip_requesting_account_id  = true
  }
}
