resource "aws_dynamodb_backup" "daily_backup" {
  table_name = aws_dynamodb_table.tf_notes_table.name
  name       = "daily-backup-${formatdate("YYYY-MM-DD", timestamp())}"
}

resource "aws_cloudwatch_event_rule" "backup_rule" {
  name        = "daily-dynamodb-backup"
  description = "Trigger daily backups for DynamoDB table"
  schedule_expression = "rate(24 hours)"
}

resource "aws_cloudwatch_event_target" "backup_target" {
  rule = aws_cloudwatch_event_rule.backup_rule.name
  arn  = aws_lambda_function.backup_handler.arn
}

resource "aws_lambda_permission" "backup_permission" {
  statement_id  = "AllowCloudWatchEventsToInvokeBackupHandler"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.backup_handler.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.backup_rule.arn
}

resource "aws_lambda_function" "backup_handler" {
  filename         = "backup.zip"
  function_name    = "dynamodb-backup-handler"
  role             = aws_iam_role.lambda_execution_role.arn
  handler          = "backup.handler"
  runtime          = "python3.8"
  source_code_hash = filebase64sha256("backup.zip")
}
