
# Provider
provider "aws" {
  region     = "us-east-1"
  access_key = "AKIAVEPN6G5T2BR54E5M"
  secret_key = "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"
}


# S3 bucket
resource "aws_s3_bucket" "project-bucket" {
  bucket = "scalerealassignment"
  acl    = "public-read-write"
}


# Adding csv file in s3 bucket

resource "aws_s3_bucket_object" "object" {
  bucket = "scalerealassignment"
  key = "project.csv"
  source = "csv data.csv"
  acl = "public-read-write"
  etag = filemd5("csv data.csv")
}


# Creating dyanamo DB
resource "aws_dynamodb_table" "dynamo_table" {
  name           = "ScaleRealAssignment"
  billing_mode   = "PROVISIONED"
  read_capacity  = 20
  write_capacity = 20
  hash_key       = "name"
  attribute {
    name="name"
    type="S"
  }
}


# Creating lambda function
resource "aws_lambda_function" "test_lambda" {
  filename      = "csvtodynamo.zip"
  function_name = "lambda_function_name"
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "csvtodynamo.lambda_handler"
  runtime = "python3.7"
}


# S3 - lambda trigger notification

resource "aws_lambda_permission" "allow_bucket" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = "lambda_function_name"
  principal     = "s3.amazonaws.com"
  source_arn    = "arn:aws:s3:::scalerealassignment"
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = "scalerealassignment"

  lambda_function {
    lambda_function_arn = "arn:aws:lambda:us-east-1:353223194471:function:lambda_function_name"
    events              = ["s3:ObjectCreated:*"]
  }

  depends_on = [aws_lambda_permission.allow_bucket]
}
