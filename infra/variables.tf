variable "api_gateway_url" {
    type = string
}

variable "dynamo_table" {
    type = string
}

variable "aws_region" {
    type = string
}

variable "stage_name" {
    type = string
    default = "dev"
}

variable "log_retention_days" {
    type = number
}

variable "account_id" {
    type = string
}