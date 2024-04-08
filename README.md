# Terraform Project

This project contains Terraform configurations for provisioning and managing infrastructure.

## Getting Started

Follow these steps to set up and run the Terraform scripts.

### Prerequisites

Before you begin, ensure you have the following installed:

- [Terraform](https://www.terraform.io/downloads.html) (version X.X.X)
- [AWS CLI](https://aws.amazon.com/cli/) (version X.X.X) configured with necessary access credentials

### Installation

1. Clone the repository:

    ```bash
    git clone [https://github.com/Amaramohamedou/demo-ECS-smartcv.git]
    ```

2. Navigate to the project directory:

    ```bash
    cd demo-ECS-smartcv
    ```

3. Initialize the working directory:

    ```bash
    terraform init
    ```

### Configuration

 1. Review and customize the files as needed to define the infrastructure resources you want to provision.
 2. useful link to provision infra [Terraform registery](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)

### Authentication

Ensure that you have configured the AWS CLI with appropriate access credentials and permissions.

```bash
aws configure
```

### Plan your infrastructure

To preview what will be created on your aws account

```bash
terraform plan
```


### Apply your infrastructure

if everything is good apply your infra

```bash
terraform apply
```
### Destroy the infrastructure

Be carefule do not leave any resource on the aws after you finished the practice run the following command :

```bash
terraform destroy
```



