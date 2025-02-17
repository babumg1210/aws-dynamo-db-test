resource "aws_dynamodb_table" "notes_table" {
  name           = "notes-table"
  billing_mode   = "PROVISIONED"
  read_capacity  = 5
  write_capacity = 5

  attribute {
    name = "noteId"
    type = "S"  # String type
  }

  hash_key = "noteId"

  ttl {
    enabled        = true
    attribute_name = "expiryPeriod"
  }

  point_in_time_recovery {
    enabled = true  # Enabling point-in-time recovery (PITR)
  }

  server_side_encryption {
    enabled = true  # Enabling encryption at rest
  }
}

resource "aws_application_autoscaling_target" "read_capacity" {
  max_capacity       = 100
  min_capacity       = 5
  resource_id        = "table/notes-table"
  scalable_dimension = "dynamodb:table:ReadCapacityUnits"
  service_namespace  = "dynamodb"
}

resource "aws_application_autoscaling_target" "write_capacity" {
  max_capacity       = 100
  min_capacity       = 5
  resource_id        = "table/notes-table"
  scalable_dimension = "dynamodb:table:WriteCapacityUnits"
  service_namespace  = "dynamodb"
}
