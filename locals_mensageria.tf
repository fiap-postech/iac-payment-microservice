locals {

  subscription = {
    payment_purchase_created = {
      name                 = "prd-purchase-created-topic"
      protocol             = "sqs"
      raw_message_delivery = true
    },
    payment_done = {
      name                 = "prd-payment-done-topic"
      protocol             = "sqs"
      raw_message_delivery = true
    },
    payment_created = {
      name                 = "prd-payment-created-topic"
      protocol             = "sqs"
      raw_message_delivery = true
    }
  }


  sqs = {
    payment_purchase_created = {
      name                       = "prd-payment-purchase-created-queue"
      delay_seconds              = 0
      max_message_size           = 262144
      message_retention_seconds  = 86400
      receive_wait_time_seconds  = 0
      visibility_timeout_seconds = 60
      sqs_managed_sse_enabled    = true
    }
  }
}