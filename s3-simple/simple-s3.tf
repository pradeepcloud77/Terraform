resource "aws_s3_bucket" "bucket1" {
  bucket = "${var.bucket_name}"
  acl    = "private"
}

resource "aws_s3_bucket_object" "object" {
  bucket = "${aws_s3_bucket.bucket1.bucket}"
  key = "<object key name>"
  source = "<full path to uploaded file>"
}