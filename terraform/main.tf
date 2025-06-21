  region = "us-east-1"
}
# key pair
resource "aws_key_pair" "my_key" {
  key_name   = "terra-key-ec2"
  public_key = file("terra-key-ec2.pub")
}

resource "aws_security_group" "lab_sg" {
  name        = "lab-security-group"
  description = "Allow SSH, HTTP, and Ansible access"

  # SSH Access
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # WARNING: Open to all (for lab only)
  }

  # HTTP Access (For Nginx)
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Allows worldwide HTTP access
  }

  # Outbound traffic (Allow all)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ansible-lab-sg"
  }
}

resource "aws_instance" "lab_instance" {
  count         = 2
  ami           = "ami-020cba7c55df1f615"  # Ubuntu in us-west-1
  instance_type = "t2.micro"
  key_name      = aws_key_pair.my_key.key_name
  vpc_security_group_ids = [aws_security_group.lab_sg.id]  # Attaches security group

  tags = {
    Name = "ansible-lab-instance-${count.index}"
  }
}

resource "local_file" "ansible_inventory" {
  filename = "../ansible/hosts.ini"
  content = templatefile("inventory.tmpl", {
    instances = aws_instance.lab_instance[*]
    ssh_user  = "ubuntu"
    ssh_key   = "/home/ubuntu/terraform-ansible-lab/terraform/terra-key-ec2"
})
}

output "instance_ips" {
  value = aws_instance.lab_instance[*].public_ip
}
