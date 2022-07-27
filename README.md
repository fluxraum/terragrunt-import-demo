

# terragrunt-import-demo

## 0. Disclaimer

Creating AWS resources may generate costs. This demo is for testing purposes to provide you with an idea of how you can import existing AWS resources into Terraform/Terragrunt. Please run this demo in `non-production` environments!

The following repository structure is inspired by [terragrunt-reference-architecture](https://github.com/antonbabenko/terragrunt-reference-architecture) but was slightly changed to fit our needs.

## 1. Prerequisites
- [Terraform](https://www.terraform.io/)
- [Terragrunt](https://terragrunt.gruntwork.io/)
- [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
- AWS Account ID
- an existing VPC in your AWS Account: [Create VPC](https://docs.aws.amazon.com/vpc/latest/userguide/working-with-vpcs.html#Create-VPC)
- the [VPC ID](https://docs.aws.amazon.com/managedservices/latest/userguide/find-vpc.html) of your existing VPC


## 2. Preparation
- Ensure you're logged into your AWS Account with [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-quickstart.html)
- Add your AWS Account ID to the `global_vars.hcl` file below `terraform/environments/demo`


## 3. Run this Demo
Export your AWS Profile

```
export AWS_PROFILE=your-profile
```

Go to the VPC directory
```
cd terraform/environments/demo/eu-central-1/networking/vpc
```

Run terragrunt plan
```
terragrunt run-all plan
```

Mark down the name of the VPC resource of the previous output. It should be something like:

```
# aws_vpc.this[0] will be created   <----- this
  + resource "aws_vpc" "this" {
      + arn                                  = (known after apply)
      ...
      ...
      ...
      + owner_id                             = (known after apply)
      + tags                                 = {
          + "Name" = "demo-vpc"
        }
      + tags_all                             = {
          + "Name" = "demo-vpc"
        }
    }
```

## 4. Import VPC

Take the VPC resource of the previous output and combine it with the VPC ID we have identified before via AWS Console.

```
terragrunt import 'aws_vpc.this[0]' 'vpc-0ec5eafbd3fa5fdee' 
```


If the import was successful you should see the message `Import successful!`
```
WARN[0000] No double-slash (//) found in source URL /terraform-aws-modules/terraform-aws-vpc.git. Relative paths in downloaded Terraform code may not work. 
aws_vpc.this[0]: Importing from ID "vpc-0ec5eafbd3fa5fdee"...
aws_vpc.this[0]: Import prepared!
  Prepared aws_vpc for import
aws_vpc.this[0]: Refreshing state... [id=vpc-0ec5eafbd3fa5fdee]

Import successful!

The resources that were imported are shown above. These resources are now in
your Terraform state and will henceforth be managed by Terraform.
```

Run the plan again and check whether the VPC resource vanished from the output. If so, the import was successful. 
```
terragrunt run-all plan
```

As you can see the output is quite longer than expected. This is because the VPC module provides many more resources than just the "VPC" itself. Theoretically, you could continue importing all the other resources as we did before. But since this demo is just to provide you with an idea of how the import process works we will omit further steps here. However, if you're hooked to continue - feel free! :-)

Bonus: if you already have infrastructure under the control of terraform and you plan to do a code-to-code migration, for example, if you want to move to terragrunt, you have to keep in mind to remove all existing resources from the terraform remote state that is related to the other codebase. And if your old codebase is under control of CI/CD, don't forget to delete the code from the old codebase before you run terragrunt apply or your pipelines.

## External Sources
- https://docs.aws.amazon.com/vpc/latest/userguide/working-with-vpcs.html#Create-VPC
- https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-quickstart.html
- https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html
- https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws/latest
- https://docs.aws.amazon.com/managedservices/latest/userguide/find-vpc.html
- https://terragrunt.gruntwork.io/
- https://www.terraform.io/

## Authors

Repository is created and maintained by [Fluxraum GmbH](https://fluxraum.com)
