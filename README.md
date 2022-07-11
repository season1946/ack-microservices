# Provision a EKS cluster with ACK

- Creates a new sample VPC, 3 Private Subnets and 3 Public Subnets
- Creates Internet gateway for Public Subnets and NAT Gateway for Private Subnets
- Creates EKS Cluster Control plane with one managed node group
- Creates IRSA for ACK API gateway, ACK DynamoDB, ACK S3 and deploy their helm charts
- Creates API gateway vpclink

## How to Deploy

### Prerequisites:

Ensure that you have installed the following tools in your Mac or Windows Laptop before start working with this module and run Terraform Plan and Apply

1. [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html)
2. [Kubectl](https://Kubernetes.io/docs/tasks/tools/)
3. [Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli)

### Deployment Steps

#### Step 1: Clone the repo using the command below

```sh
git clone https://github.com/season1946/ack-microservices.git
```

#### Step 2: Run Terraform INIT

Initialize a working directory with configuration files

```sh
cd eks-ack-provision
terraform init
```

#### Step 3: Run Terraform PLAN

Verify the resources created by this execution

```sh
terraform plan -var-file base.tfvars
```

#### Step 4: Finally, Terraform APPLY

**Deploy the pattern**

```sh
terraform apply -var-file base.tfvars
```

Enter `yes` to apply.


#### Step 5: Deploy miscroservice api infra through kubectl commands
login the eks cluster

```sh
aws eks --region <enter-your-region> update-kubeconfig --name <cluster-name>
cd ..
cd k8s-infra
```

- replace {your dynamo db role} in internal-alb-dynamo.yaml with dynamo-rw_role_arn in terraform apply output. kubectl apply -f internal-alb-dynamo.yaml
- get the newly depolyed ALB license arn 
```sh
export AGW_AWS_REGION=<your region>
aws elbv2 describe-listeners \
  --load-balancer-arn $(aws elbv2 describe-load-balancers \
  --region $AGW_AWS_REGION \
  --query "LoadBalancers[?contains(DNSName, '$(kubectl get ingress ingress-api-dynamo -o=jsonpath="{.status.loadBalancer.ingress[].hostname}")')].LoadBalancerArn" \
  --output text) \
  --region $AGW_AWS_REGION \
  --query "Listeners[0].ListenerArn" \
  --output text
```
- replace {your ALB listener arn} in apigwv2-httpapi.yaml with the value above and replace {your vpclink id} with apigw_vpclink_id in terraform apply output, then kubectl apply -f apigwv2-httpapi.yaml
- deploy a DynamonDB table, kubectl apply -f dynamodb-table.yaml

#### Step 6: test your api 
Get your api domain 
```sh
 kubectl get api  ack-api  -o jsonpath="{.status.apiEndpoint}"
```
then post data to dynamodb with post and query data with get

post {your api domain}/rows/add with json payload
{
            "name": "external"
}

get {your api domain}/rows/all

## Cleanup

To clean up your environment, destroy the Terraform modules in reverse order.

Destroy the Kubernetes Add-ons, EKS cluster with Node groups and VPC

```sh
cd ..
kubectl delete -f k8s-infra/
cd eks-ack-provision
terraform destroy -target="module.eks_blueprints_kubernetes_addons" -var-file base.tfvars -auto-approve
terraform destroy -target="module.eks_blueprints" -var-file base.tfvars -auto-approve
terraform destroy -target="module.vpc" -var-file base.tfvars -auto-approve
```

Finally, destroy any additional resources that are not in the above modules

```sh
terraform destroy -var-file base.tfvars -auto-approve
```
