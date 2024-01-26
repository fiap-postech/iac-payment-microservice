locals {
  api_gateway = {
    id = "strojk6q35"

    vpc_link = {
      id = "zx34is"
    }

    integration = {
      integration_type       = "HTTP_PROXY"
      integration_method     = "ANY"
      connection_type        = "VPC_LINK"
      payload_format_version = "1.0"
    }
  }
}