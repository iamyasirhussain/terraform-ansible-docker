# terraform-ansible-docker
In this lab we'll provisioned aws resources via terraform and manage connected hosts via ansible but this time with docker container
navigate to terraform/
ssh-keygen
name : terra-key-ec2
update main.tf with key name
We'll use aws_key_pair block
docker run --rm -it   -v "$PWD":/lab   -v "$PWD/terraform/terra-key-ec2":/root/.ssh/id_rsa:ro   -w /lab/ansible   alpine/ansible   ansible-playbook -i hosts.ini nginx.yml
