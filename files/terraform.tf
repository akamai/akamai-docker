terraform {
  required_providers {
    akamai = {
      source = "akamai/akamai"
      version = "3.5.0"
    }

    null = {
      source = "hashicorp/null"
      version = "3.0.0"
    }

    local = {
      source = "hashicorp/local"
      version = "2.0.0"
    }

    jsonnet = {
      source = "alxrem/jsonnet"
      version = "1.0.3"
    }
  }
}
