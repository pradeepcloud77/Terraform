data "template_file" "userdata"{
  template = "${file("registry.sh")}"

  vars {
    access_key = "${var.access_key}"
    secret_key = "${var.secret_key}"
    region = "${var.symphony_ip}"
    bucket_name = "${var.bucket_name}"
  }
}

resource "aws_s3_bucket" "bucket1" {
  bucket = "${var.bucket_name}"
  acl    = "private"
}

resource "aws_instance" "docker-repository" {
  ami = "${var.ami_id}"
  instance_type = "c3.xlarge"
  user_data =  "${data.template_file.userdata.rendered}"
  key_name = "${var.key_pair}"

  depends_on = ["aws_s3_bucket.bucket1"]
}

output "registry" {
  value = "${aws_instance.docker-repository.private_ip}"
}