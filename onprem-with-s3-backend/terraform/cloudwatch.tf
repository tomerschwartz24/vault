resource "aws_cloudwatch_metric_alarm" "vault_alarm" {
  alarm_name                = "${var.cloudwatch_alarm_name}"
  comparison_operator       = "LessThanThreshold"
  evaluation_periods        = var.cloudwatch_alarm_evaluation_periods
  metric_name               = "${var.cloudwatch_alarm_metric_name}"
  namespace                 = "${var.cloudwatch_alarm_namespace}"
  period                    = var.cloudwatch_alarm_period
  statistic                 = "Average"
  threshold                 = var.cloudwatch_alarm_threshold
  alarm_description         = "${var.cloudwatch_alarm_description}"
  treat_missing_data = "${var.cloudwatch_alarm_treat_missing_data}"
  alarm_actions = [aws_lambda_function.test_lambda.arn]
}