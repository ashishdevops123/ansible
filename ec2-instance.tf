resource "aws_instance" "ubuntu" {
    
    ami                         = var.ec2_ami
    instance_type               = var.ec2_size
    subnet_id                   = aws_subnet.subnet[0].id
    associate_public_ip_address = true
    key_name                    ="kubernetes"
    vpc_security_group_ids      = [aws_security_group.web_sg.id]
    tags = {
      name = "myec2"
      env  = "development"
    }
}
  
// for null resource


resource "null_resource" "inlinescript" {
  triggers = {
    build_id = var.build_id
  }


  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file("./kubernetes.pem")
    host        = aws_instance.ubuntu.public_ip
  }

provisioner "remote-exec" {
    inline = [
        "sudo apt update",
        "sudo apt install git -y"
      
    ]
    
}

provisioner "remote-exec" {
        inline = [
          "sudo apt update",
          "sudo apt install python3  -y",
         
        ]
    }
   
   

provisioner "local-exec" {
        command = "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -u ubuntu -i all '${aws_instance.ubuntu.public_ip},' --private-key './kubernetes.pem' /home/ubuntu/jenkins/ansible.tomcat.yaml"
      
    }    

}




