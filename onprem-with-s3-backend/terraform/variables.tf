variable "cloudwatch_alarm_name" {
  description = "The name of the cloudwatch alarm"
  default     = "on-prem-vault-alarm"
  type        = string
}

variable "cloudwatch_alarm_evaluation_periods" {
  description = "How many iterations periods before considering it 'In Alarm' "
  default     = 3
  type        = number
}

variable "cloudwatch_alarm_metric_name" {
  description = "the metric name to watch for alarms, should be the same as in the heartbeat.py"
  default     = "VaultIsRunning"
  type        = string
}

variable "cloudwatch_alarm_namespace" {
    description = "namespace of metric, should be the same as in heartbeat.py"
    default     = "Custom/VaultHeartbeat"
    type        = string
}

variable "cloudwatch_alarm_description" {
    description = "description of alarm"
    default     = "Checking whether the on-prem vault instance is available"
    type        = string 
  
}

variable "cloudwatch_alarm_period" {
  description = "The period in seconds over which the specified statistic is applied"
  default     = 30
  type        = number
}

variable "cloudwatch_alarm_threshold" {
  description = "The value against which the specified statistic is compared. This parameter is required for alarms based on static thresholds."
  default     = 1 #whenever "vaultisrunning is lower than 1"
  type        = number
}

variable "cloudwatch_alarm_treat_missing_data" {
  description = "How to treat missing data? is it - missing, ignore, breaching, notBreaching"
  default     = "missing"
  type        = string
}

variable "region" {
  description = "region in aws"
  default     = "eu-central-1"
  type        = string
}

variable "bucket_name" {
  description = "vault backend bucket name"
  default     = "myvault-backend"
  type        = string
}
