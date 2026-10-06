# data.tf reads professor-created resources (Terraform does NOT manage these)
data "aws_vpc" "main" { tags = { Name = "AWS-VPCB-VPC" } }
data "aws_subnet" "public" { tags = { Name = "AWS-VPCB-PUBLIC" } }
# Finds the most recently built Packer AMI without needing
data "aws_iam_role" "lab" {
  name = "LabRole"
}
data "aws_network_interface" "nat" {
  filter {
    name   = "attachment.instance-id"
    values = [data.aws_instance.control_node.id]
  }
}
data "aws_instance" "control_node" {
  filter {
    name   = "tag:Name"
    values = ["AWS-VPCB-NAT"]
  }
}
data "aws_ami" "mysql_golden" {
  most_recent = true
  owners      = ["self"] # AMIs in your own Academy account
  filter {
    name   = "name"
    values = ["mysql-golden-*"] # matches the Packer ami_name pattern
  }
  filter {
    name   = "tag:BuiltBy"
    values = ["packer"]
  }
}
