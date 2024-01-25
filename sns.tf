resource "aws_sns_topic" "payment_done_topic" {
  name                                  = local.sns.payment_done.name
  firehose_success_feedback_sample_rate = 0
  http_success_feedback_sample_rate     = 0
  kms_master_key_id                     = local.sns.payment_done.kms_master_key_id
  delivery_policy = jsonencode(
    {
      http : {
        defaultHealthyRetryPolicy : {
          minDelayTarget     = local.sns.payment_done.min_delay_target,
          maxDelayTarget     = local.sns.payment_done.max_delay_target,
          numRetries         = local.sns.payment_done.num_retries,
          numMaxDelayRetries = local.sns.payment_done.num_max_delay_retries,
          numNoDelayRetries  = local.sns.payment_done.num_no_delay_retries,
          numMinDelayRetries = local.sns.payment_done.num_min_delay_retries,
        },
        disableSubscriptionOverrides = local.sns.payment_done.disable_subscription_overrides,
        defaultThrottlePolicy : {
          maxReceivesPerSecond = local.sns.payment_done.max_receives_per_second
        }
      }
    }
  )
}

resource "aws_sns_topic" "payment_created_topic" {
  name                                  = local.sns.payment_created.name
  firehose_success_feedback_sample_rate = 0
  http_success_feedback_sample_rate     = 0
  kms_master_key_id                     = local.sns.payment_created.kms_master_key_id
  delivery_policy = jsonencode(
    {
      http : {
        defaultHealthyRetryPolicy : {
          minDelayTarget     = local.sns.payment_created.min_delay_target,
          maxDelayTarget     = local.sns.payment_created.max_delay_target,
          numRetries         = local.sns.payment_created.num_retries,
          numMaxDelayRetries = local.sns.payment_created.num_max_delay_retries,
          numNoDelayRetries  = local.sns.payment_created.num_no_delay_retries,
          numMinDelayRetries = local.sns.payment_created.num_min_delay_retries,
        },
        disableSubscriptionOverrides = local.sns.payment_created.disable_subscription_overrides,
        defaultThrottlePolicy : {
          maxReceivesPerSecond = local.sns.payment_created.max_receives_per_second
        }
      }
    }
  )
}