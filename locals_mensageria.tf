locals {
  sns = {
    payment_done = {
      name                           = "prd-payment-done-topic"
      min_delay_target               = 20
      max_delay_target               = 20
      num_retries                    = 3
      num_max_delay_retries          = 0
      num_no_delay_retries           = 0
      num_min_delay_retries          = 0
      disable_subscription_overrides = false
      max_receives_per_second        = 10
      kms_master_key_id              = "alias/aws/sns"
    },
    payment_created = {
      name                           = "prd-payment-created-topic"
      min_delay_target               = 20
      max_delay_target               = 20
      num_retries                    = 3
      num_max_delay_retries          = 0
      num_no_delay_retries           = 0
      num_min_delay_retries          = 0
      disable_subscription_overrides = false
      max_receives_per_second        = 10
      kms_master_key_id              = "alias/aws/sns"
    }
  }
}