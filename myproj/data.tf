data "vault_generic_secret" "my_access_key" {
  path = "secret/vlt_usr_access_key"
}

data "vault_generic_secret" "my_secret_key" {
  path = "secret/vlt_usr_secret_key"
  
}