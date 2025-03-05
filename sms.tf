resource "aws_pinpointsmsvoicev2_opt_out_list" "workshop" {
  name = "product_survey"
}

resource "aws_cloudwatch_log_group" "sms_messaging_log_group" {
  name              = "/${lower(var.app_name)}/${lower(var.environment)}/sms-messaging"
  retention_in_days = 1

  tags = {
    Environment = var.environment
  }
}

resource "aws_pinpointsmsvoicev2_configuration_set" "configuration-set" {
  name                 = "${var.app_name}-${var.environment}-configset"
  default_sender_id    = "${upper(var.app_name)}-SUP"
  default_message_type = "TRANSACTIONAL"

  tags = {
    Environment = var.environment
  }
}
