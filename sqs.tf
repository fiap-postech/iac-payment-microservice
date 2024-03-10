resource "aws_sqs_queue" "payment_purchase_created_queue" {
  name                       = local.sqs.payment_purchase_created.name
  delay_seconds              = local.sqs.payment_purchase_created.delay_seconds
  max_message_size           = local.sqs.payment_purchase_created.max_message_size
  message_retention_seconds  = local.sqs.payment_purchase_created.message_retention_seconds
  receive_wait_time_seconds  = local.sqs.payment_purchase_created.receive_wait_time_seconds
  visibility_timeout_seconds = local.sqs.payment_purchase_created.visibility_timeout_seconds
  sqs_managed_sse_enabled    = local.sqs.payment_purchase_created.sqs_managed_sse_enabled

  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.payment_purchase_created_dlq.arn,
    maxReceiveCount     = 3
  })

  redrive_allow_policy = jsonencode({
    redrivePermission = "byQueue",
    sourceQueueArns   = ["${aws_sqs_queue.payment_purchase_created_dlq.arn}"]
  })

  depends_on = [
    aws_sqs_queue.payment_purchase_created_dlq
  ]
}

resource "aws_sqs_queue" "payment_purchase_created_dlq" {
  name                       = "${local.sqs.payment_purchase_created.name}-dlq"
  delay_seconds              = local.sqs.payment_purchase_created.delay_seconds
  max_message_size           = local.sqs.payment_purchase_created.max_message_size
  message_retention_seconds  = local.sqs.payment_purchase_created.message_retention_seconds
  receive_wait_time_seconds  = local.sqs.payment_purchase_created.receive_wait_time_seconds
  visibility_timeout_seconds = local.sqs.payment_purchase_created.visibility_timeout_seconds
  sqs_managed_sse_enabled    = local.sqs.payment_purchase_created.sqs_managed_sse_enabled
}

resource "aws_sns_topic_subscription" "get_payment_purchase_created_events" {
  topic_arn            = data.aws_sns_topic.payment_purchase_created.arn
  protocol             = local.subscription.payment_purchase_created.protocol
  endpoint             = aws_sqs_queue.payment_purchase_created_queue.arn
  raw_message_delivery = local.subscription.payment_purchase_created.raw_message_delivery

  depends_on = [
    aws_sqs_queue.payment_purchase_created_queue,
    data.aws_sns_topic.payment_purchase_created
  ]
}

resource "aws_sqs_queue_policy" "payment_purchase_created_to_process_subscription" {
  queue_url = aws_sqs_queue.payment_purchase_created_queue.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "sns.amazonaws.com"
        },
        Action : [
          "sqs:SendMessage"
        ],
        Resource = [
          aws_sqs_queue.payment_purchase_created_queue.arn
        ],
        Condition = {
          ArnEquals = {
            "aws:SourceArn" : data.aws_sns_topic.payment_purchase_created.arn
          }
        }
      }
    ]
  })
}