# DevOps assignment (IaC)
Task is done, code destroys and applies smoothly. ✅

Goal: Implement Terraform code, which would deploy an EC2 instance, running within ASG with ELB in front of it. This instance, through ELB, should share port 22 (SSH port) to outside Internet. 
In 	general infrastructure should look like this. Internet --> ELB --> ASG( EC2 )

--------
## Instrurcions
Better to start with `./main.sh`

--------
### Difficulties
- The most problematic thing was to pass credential data WHILE using (Terraform Cloud)[app.terraform.io] for storing .tfstate file on a remote server.
Obviously **tfe**  provider blocks such attempts. 
So I removed `backend "remote"` from **.tf** file and passed credentials by user's input. 
*According to above, how to get sensetive varables from Terraform cloud?* Those ones are already typed in Organization -> Workspace -> Variables section.
- *How to get list of instances attached to newly created ASG?*
- *How to recreate ASG instances when Resource Template was changed?*


(AWS)[https://docs.aws.amazon.com/index.html]
(Terraform HashiCorp)[https://registry.terraform.io/providers/hashicorp/aws/latest]