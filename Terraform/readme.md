**Terraform** is an open-source infrastructure as code software. It is commonly used by SRE, DevOps Engineer, Data Engineer to build realiable and consistent infrastructure

This is where to host projects to learn terraform on different cloud platforms

## self-summarized notes:

1. If just comment out the chunks of resource code, terraform will destroy it automatically
2. The order of code in terraform doesn’t matter
3. > [!IMPORTANT] Terraform **tfstate** is a very important file and never change it 
4. Define variable:
    -If the value is not specified, terraform will ask the user to enter value during terraform apply. Or use command line: terraform apply -var “subnet_prefix=10.0.100.0/24”
    -Best way to assign terraform variables to create a separate file Terraform.tfvars. 
    -Have different tfvars files instead of default terraform.tfvars. And pass it in the command: terraform apply -var-file (Tfvar file name)
    -can also use list and reference the variable by index

Some basic terraform commands are:
```
Terraform (hit enter) : list all the available commands
Terraform init : initialize terraform
Terraform plan :display what needs to be added or removed, security checks
Terraform apply :run terraform build
Terraform destroy: destory the whole infrastructure
Terraform state list 
Terraform state show “resource name”: show detail information on the resource
Terraform destroy -target resource_name: only destroy that resource
Terraform apply -target resource_name: only build that resource
```
## Useful youtube videos:

https://www.youtube.com/watch?v=SLB_c_ayRMo


## My saved Medium articles:

https://medium.com/@jaden09/list/terraform-abd395c835b9


## Other useful links:




