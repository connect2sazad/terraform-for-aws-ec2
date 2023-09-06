# data sourc
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["${var.owners}"]

  filter {
    name   = "name"
    values = ["${var.image_name}"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}


# instance
resource "aws_instance" "web" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  key_name               = aws_key_pair.key-tf.key_name
  vpc_security_group_ids = ["${aws_security_group.allow_tls.id}"]
  tags = {
    Name = "first-tf-instance"
  }
  user_data = file("${path.module}/script.sh")

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file("${path.module}/id_rsa")
    host        = self.public_ip
  }

  # file, local-exec, remote-exec
  provisioner "file" {
    source      = "README.md"
    destination = "/tmp/README.md"
  }

  provisioner "file" {
    on_failure  = continue
    content     = "this is a testing"
    destination = "/tmp/content.md"
  }

  # provisioner "local-exec" {
  #   command = "echo ${self.public_ip} > public_ip1.txt"
  # }

  # provisioner "local-exec" {
  #   working_dir = "${path.module}/tmp/"
  #   command = "echo ${self.private_ip} > private_ip.txt"
  # }

  # provisioner "local-exec" {
  #   interpreter = [
  #     "C:/Users/Anmol/AppData/Local/Programs/Python/Python310/python.exe", "-c"
  #   ]
  #   command = "print('Hello World')"
  # }

  provisioner "local-exec" {
    command = "echo 'at creation'"
  }

  provisioner "local-exec" {
    when    = destroy
    command = "echo 'at delete'"
  }

  # provisioner "remote-exec" {
  #   when = destroy
  #   command = "echo 'at delete'"
  # }
}


