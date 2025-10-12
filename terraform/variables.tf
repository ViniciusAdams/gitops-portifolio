variable "region" {
  type    = string
  default = "eu-west-1"
}

variable "bucket_name" {
  type        = string
  description = "Name of existing S3 bucket that stores the Lambda zip file"
  default     = "viniciusadams.com"
}

variable "lambda_s3_key" {
  type        = string
  description = "S3 object key (path to Lambda zip in the bucket)"
}

variable "lambda_function_name" {
  type    = string
  default = "trivia_lambda"
}