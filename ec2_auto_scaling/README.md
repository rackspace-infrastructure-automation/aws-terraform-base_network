# EC2 AutoScaling Module

## Usage
```hcl
module "autoscaling_group" {
  source = "git@github.com:rackspace-infrastructure-automation/rackspace-aws-terraform//ec2_auto_scaling"

  environment = "REQUIRED_EDIT_ME"
  name = "REQUIRED_EDIT_ME"
  ami_id = "REQUIRED_EDIT_ME"
  instance_type = "REQUIRED_EDIT_ME"
  security_groups = []
  asg_sizes = {
      min_size = 2
      max_size = 3
  }
  subnet_ids = ["LIST_REQUIRED_EDIT_ME"]
}
```
