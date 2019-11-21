Hi, Here is the echo server project
Here is the instructions
1. Use the packer version 1.4.5 
   (you can download it from here https://www.packer.io/downloads.html)
   put the "packer" file by replace it with "packer_file_location" file
2. Use terraform version 0.12.16
   (you can download it from here https://www.terraform.io/downloads.html)
   put the "terraform" file by replace it with "terraform_file_location" file
3. Put your azure credentials + existing ressource-group name in "run.sh" file
4. Run the "run.sh" file for image creating the deployment to azure
5. The run.sh file output is ai ip's array, the last ip adress is the load balancer ip that you can use in order to check the solution
   for example by "curl {last-ip} -d "Hi" "

Note: If terraform said that the ip address not found just run the run.sh file again

Enjoy!!!