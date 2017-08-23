/*
  EC2 Auto Scaling Module
  Fanatical Support for Amazon Web Services
  Rackspace
*/

## Variables

# Descriptive name of the Environment to add to tags (should make sense to humans)
variable "environment" {
  type = "string"
  description = "The Environment this VPC is being deployed into (prod, dev, test, etc)"
}
# Name to give to the ASG and associated resources
variable "name" {
  type = "string"
}
# AMI ID to use in the Launch Configuration
variable "ami_id" {
  type = "string"
}
# Instance Type to launch
variable "instance_type" {
  type = "string"
}
# Security Group IDs to launch with
variable "security_groups" {
  type = "list"
}
# AutoScaling Sizes
variable "asg_sizes" {
  type = "map"

  default = {
    # Minimum Size of ASG
    min_size = 2
    # Maximum Size of ASG
    max_size = 3
  }
}
# Subnet IDs to launch into
variable "subnet_ids" {
  type = "list"
}

## Resources

# Launch Configuration for the AutoScaling Group
resource "aws_launch_configuration" "launch_configuration" {
  # Using `name_prefix` to ensure randomly generated LCs
  name_prefix     = "${var.name}-launchconfiguration-"
  image_id        = "${var.ami_id}"
  instance_type   = "${var.instance_type}"
  security_groups = ["${var.security_groups}"]

  lifecycle {
    # Ensure a new Launch Configuration is created before destroying the old one
    create_before_destroy = true
  }
}
# AutoScaling Group
resource "aws_autoscaling_group" "autoscaling_group" {
  name                 = "${var.name}-asg"
  launch_configuration = "${aws_launch_configuration.launch_configuration.name}"
  min_size             = "${var.asg_sizes["min_size"]}"
  max_size             = "${var.asg_sizes["max_size"]}"
  vpc_zone_identifier  = ["${var.subnet_ids}"]
  tags = [
    {
      key                 = "Environment"
      value               = "${var.environment}"
      propagate_at_launch = true
    },
    {
      key                 = "Provisioner"
      value               = "rackspace"
      propagate_at_launch = true
    }
  ]

  lifecycle {
    # Ensure a new ASG is created before destroying the old one
    create_before_destroy = true
  }
}
