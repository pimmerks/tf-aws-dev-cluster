# TF dev EKS cluster

This project provisions a development cluster within AWS.

## Plan and apply
```shell
# Set AWS_PROFILE to the correct value
export AWS_PROFILE=<val>

# Plan outputs the terraform plan and creates the .plan file.
make plan

# Apply applies the .plan file.
make apply
```

## Destroy
```shell
# Set AWS_PROFILE to the correct value
export AWS_PROFILE=<val>

make destroy
```
