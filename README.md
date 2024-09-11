# TF dev EKS cluster

This project provisions a development cluster within AWS.

## Setup
Create an `.env` file by `cp .env.example .env`, and fill it in.
Note, for state backend, this uses [Terraform Cloud](https://app.terraform.io/).

## Plan and apply
```shell
# Plan outputs the terraform plan and creates the .plan file.
make plan

# Apply applies the .plan file.
make apply
```

## Destroy
```shell
make destroy
```
