# Create instances, and name them according to count

# Defining cloud config template file 

data "template_file" "ebsdeploy"{
  template = "${file("./cloudconfig.cfg")}"
}

data "template_cloudinit_config" "ebsdeploy_config" {
  gzip = false
  base64_encode = false

  part {
    filename     = "cloudconfig.cfg"
    content_type = "text/cloud-config"
    content      = "${data.template_file.ebsdeploy.rendered}"
  }
}


resource "aws_instance" "ec2_instance" {
    ami = "${var.ami_image}"

    tags{
        Name="instance${count.index}"
    }
    
    instance_type = "${var.instance_type}"
    count="${var.instance_number}"

    user_data = "${data.template_cloudinit_config.ebsdeploy_config.rendered}"

    root_block_device { 
        # Enter larger volume size here in GB, must be larger than images base size
        volume_size = 250
    }

}
