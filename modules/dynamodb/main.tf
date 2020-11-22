resource "aws_dynamodb_table" "mwa_table" {
  name           = "MysfitsTable"
  billing_mode   = "PROVISIONED"
  read_capacity  = 5
  write_capacity = 5
  hash_key       = "MysfitId"

  attribute {
    name = "MysfitId"
    type = "S"
  }

  attribute {
    name = "GoodEvil"
    type = "S"
  }

  attribute {
    name = "LawChaos"
    type = "S"
  }

  global_secondary_index {
    name            = "LawChaosIndex"
    hash_key        = "LawChaos"
    range_key       = "MysfitId"
    write_capacity  = 5
    read_capacity   = 5
    projection_type = "ALL"
  }

  global_secondary_index {
    name            = "GoodEvilIndex"
    hash_key        = "GoodEvil"
    range_key       = "MysfitId"
    write_capacity  = 5
    read_capacity   = 5
    projection_type = "ALL"
  }

  tags = {
    environment = var.environment
  }
}
