resource "aws_dynamodb_table" "basic-dynamodb-table" {
  name           = var.dynamo_table
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "id"

  attribute {
    name = "id"
    type = "S"
  }

  tags = {
    Name        = "dynamodb-table-1"
    Environment = var.stage_name
  }
}
