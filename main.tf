# Specify your provider

provider "aws" {
  region = "us-east-1"
  access_key = "YOUR ACCESS KEY HERE"
  secret_key = "YOUR SECRET ACCESS KEY HERE"
}

variable "aws_region" {
    default = "YOUR REGION NAME"
}

variable "aws_accountId" {
    default = "YOUR ACCOUND ID"
}

# Creating S3 bucket

resource "aws_s3_bucket" "project-bucket" {
  bucket = "scalerealassignment"
  acl    = "public-read-write"
}


# Creating dyanamo DB

resource "aws_dynamodb_table" "dynamo_table" {
  name           = "ScaleRealAssignment"
  billing_mode   = "PROVISIONED"
  read_capacity  = 20
  write_capacity = 20
  hash_key       = "id"
  attribute {
    name="id"
    type="S"
  }
}

# Creating lambda function to add data into dynamoDB

resource "aws_lambda_function" "csv_to_dynamo" {
  filename      = "csvtodynamo.zip"
  function_name = "CSV_To_DynamoDB"
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "csvtodynamo.lambda_handler"
  runtime = "python3.7"
}

# S3 - lambda trigger notification

resource "aws_lambda_permission" "allow_bucket" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.csv_to_dynamo.arn
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.project-bucket.arn
}

# S3 bucket event notification

resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = "scalerealassignment"

  lambda_function {
    lambda_function_arn = aws_lambda_function.csv_to_dynamo.arn
    events              = ["s3:ObjectCreated:*"]
  }

  depends_on = [aws_lambda_permission.allow_bucket]
}

# API to perform CRUD operation on dynamoDB

resource "aws_api_gateway_rest_api" "api" {
  name        = "CRUD"
  description = "This API is for performing CRUD operation on dynamoDB"
  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

# creating resource 

resource "aws_api_gateway_resource" "resource" {
  path_part   = "CRUD"
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
}

# POST Method to perform put_item and update_iteam operation on dynamoDB 

resource "aws_api_gateway_method" "post" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.resource.id
  http_method   = "POST"
  authorization = "NONE"
}

# Integrating POST method with lambda function

resource "aws_api_gateway_integration" "post_integration" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.resource.id
  http_method             = aws_api_gateway_method.post.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.post_lambda.invoke_arn
}

# POST lambda function to perform put and update operation

resource "aws_lambda_function" "post_lambda" {
  filename      = "put.zip"
  function_name = "post"
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "put.lambda_handler"
  runtime       = "python3.7"
}

# Implementing POST lambda function with POST method API gateway

resource "aws_lambda_permission" "apigw_post" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = "post"
  principal     = "apigateway.amazonaws.com"
  source_arn = "arn:aws:execute-api:${var.aws_region}:${var.aws_accountId}:${aws_api_gateway_rest_api.api.id}/*/${aws_api_gateway_method.post.http_method}${aws_api_gateway_resource.resource.path}"
}

# GET Method to perform get_item operation on dynamoDB

resource "aws_api_gateway_method" "get" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.resource.id
  http_method   = "GET"
  authorization = "NONE"
}

# Integration GET method with lambda function

resource "aws_api_gateway_integration" "get_integration" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.resource.id
  http_method             = aws_api_gateway_method.get.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.get_lambda.invoke_arn
}



# GET lambda function to perform get operation

resource "aws_lambda_function" "get_lambda" {
  filename      = "exports.zip"
  function_name = "get"
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "exports.handler"
  runtime       = "nodejs10.x"
}


# Implementing GET lambda function with GET method API gateway

resource "aws_lambda_permission" "apigw_get" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = "get"
  principal     = "apigateway.amazonaws.com"
  source_arn = "arn:aws:execute-api:${var.aws_region}:${var.aws_accountId}:${aws_api_gateway_rest_api.api.id}/*/${aws_api_gateway_method.post.http_method}${aws_api_gateway_resource.resource.path}"
}

# DELETE Method to perform get_item operation on dynamoDB

resource "aws_api_gateway_method" "delete" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.resource.id
  http_method   = "DELETE"
  authorization = "NONE"
}

# Integration Delete method with lambda function

resource "aws_api_gateway_integration" "delete_integration" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.resource.id
  http_method             = aws_api_gateway_method.delete.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.delete_lambda.invoke_arn
}

#  Implementing POST lambda function with POST method API gateway

resource "aws_lambda_permission" "apigw_delete" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.delete_lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn = "arn:aws:execute-api:${var.aws_region}:${var.aws_accountId}:${aws_api_gateway_rest_api.api.id}/*/${aws_api_gateway_method.delete.http_method}${aws_api_gateway_resource.resource.path}"
}

# GET lambda function to perform get operation

resource "aws_lambda_function" "delete_lambda" {
  filename      = "index.zip"
  function_name = "delete"
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "index.lambda_handler"
  runtime       = "nodejs10.x"
}

# Deploying API at production stage

resource "aws_api_gateway_deployment" "API_deployment" {
  depends_on = [aws_api_gateway_integration.get_integration]

  rest_api_id = aws_api_gateway_rest_api.api.id
  stage_name  = "production"

  variables = {
    "answer" = "42"
  }

  lifecycle {
    create_before_destroy = true
  }
}