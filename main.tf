# Define the DynamoDB table
resource "aws_dynamodb_table" "tf_notes_table" {
  name             = "tf-notes-table"
  billing_mode     = "PROVISIONED"
  read_capacity    = 30
  write_capacity   = 30

  attribute {
    name = "noteId"
    type = "S"
  }

  hash_key = "noteId"

  ttl {
    enabled         = true
    attribute_name  = "expiryPeriod"
  }

  point_in_time_recovery {
    enabled = true
  }

  server_side_encryption {
    enabled = true
  }

  lifecycle {
    ignore_changes = [ "write_capacity", "read_capacity" ]
  }
}

# Define the auto-scaling for read capacity
resource "aws_appautoscaling_target" "read_capacity" {
  max_capacity       = 50
  min_capacity       = 10
  resource_id        = "table/${aws_dynamodb_table.tf_notes_table.name}"
  scalable_dimension = "dynamodb:table:ReadCapacityUnits"
  service_namespace  = "dynamodb"
}
resource "aws_appautoscaling_policy" "read_policy" {
  name               = "read-scaling-policy"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.read_capacity.resource_id
  scalable_dimension = aws_appautoscaling_target.read_capacity.scalable_dimension
  service_namespace  = aws_appautoscaling_target.read_capacity.service_namespace

  target_tracking_scaling_policy_configuration {
    target_value       = 70.0
    predefined_metric_specification {
      predefined_metric_type = "DynamoDBReadCapacityUtilization"
    }
  }
}
# Define the auto-scaling for write capacity
resource "aws_appautoscaling_target" "write_capacity" {
  max_capacity       = 50
  min_capacity       = 10
  resource_id        = "table/${aws_dynamodb_table.tf_notes_table.name}"
  scalable_dimension = "dynamodb:table:WriteCapacityUnits"
  service_namespace  = "dynamodb"
}
resource "aws_appautoscaling_policy" "write_policy" {
  name               = "write-scaling-policy"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.write_capacity.resource_id
  scalable_dimension = aws_appautoscaling_target.write_capacity.scalable_dimension
  service_namespace  = aws_appautoscaling_target.write_capacity.service_namespace

  target_tracking_scaling_policy_configuration {
    target_value       = 70.0
    predefined_metric_specification {
      predefined_metric_type = "DynamoDBWriteCapacityUtilization"
    }
  }
}
