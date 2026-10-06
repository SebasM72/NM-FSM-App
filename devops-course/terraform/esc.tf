
# ecs.tf — auto-scale (cost control)
data "archive_file" "scale_lambda" {
  type        = "zip"
  output_path = "${path.module}/scale_lambda-${terraform.workspace}.zip"
  source {
    filename = "index.py"
    content  = <<-PY
import boto3
ecs = boto3.client('ecs')
def handler(event, context):
count = 0 if event['detail']['state'] == 'stopped' else 1
ecs.update_service(cluster='${aws_ecs_cluster.main.name}',
service='flask-${terraform.workspace}',
desiredCount=count)
PY
  }
}
resource "aws_lambda_function" "ecs_follow_db" {
  function_name    = "ecs-follow-db-${terraform.workspace}"
  role             = data.aws_iam_role.lab.arn # LabRole
  runtime          = "python3.12"
  handler          = "index.handler"
  filename         = data.archive_file.scale_lambda.output_path
  source_code_hash = data.archive_file.scale_lambda.output_base64sha256
}
# Fire on THIS workspace's MySQL instance state changes
resource "aws_cloudwatch_event_rule" "mysql_state" {
  name = "mysql-state-${terraform.workspace}"
  event_pattern = jsonencode({
    source        = ["aws.ec2"]
    "detail-type" = ["EC2 Instance State-change Notification"]
    detail = {
      state         = ["stopped", "running"]
      "instance-id" = [aws_instance.mysql_db.id]
    }
  })
}
resource "aws_cloudwatch_event_target" "scale" {
  rule = aws_cloudwatch_event_rule.mysql_state.name
  arn  = aws_lambda_function.ecs_follow_db.arn
}
resource "aws_lambda_permission" "eventbridge" {
  statement_id  = "AllowEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.ecs_follow_db.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.mysql_state.arn
}
