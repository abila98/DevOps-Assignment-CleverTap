# Get latest wordpress ami

data "aws_ami" "latest_ami" {
  most_recent = true

  filter {
    name   = "name"
    values = ["*(SupportedImages)*-*Wordpress*-*Ubuntu*16*x86_64*-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["679593333241"] 

}
