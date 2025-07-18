variable "aws_region" {
    type = string
    default = "sa-east-1"
}

variable "stage_name" {
    type = string
}

variable "log_retention_days" {
    type = number
    default = 1
}

