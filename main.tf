provider "aws" {
  region = var.region
}

data "aws_availability_zones" "available" {}

locals {
  cluster_name = "5inque-eks"
}

resource "random_string" "suffix" {
  length  = 8
  special = false
}

module "vpc1" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.19.0"

  name = "eks-vpc"
  cidr = "10.0.0.0/16"
  azs  = slice(data.aws_availability_zones.available.names, 0, 3)

  private_subnets = ["10.0.1.0/24", "10.0.3.0/24", "10.0.5.0/24"]
  public_subnets  = ["10.0.2.0/24", "10.0.4.0/24", "10.0.6.0/24"]

  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true

  public_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                      = 1
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"             = 1
  }
}


module "vpc2" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.19.0"

  name = "cicd-vpc"
  cidr = "172.30.0.0/24"
  azs  = slice(data.aws_availability_zones.available.names, 0, 3)

  private_subnets = ["172.30.0.128/27","172.30.0.192/27"]
  public_subnets  = ["172.30.0.0/27","172.30.0.96/27"]

  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true
}

resource "aws_vpc_peering_connection" "this" {
  peer_vpc_id = module.vpc1.vpc_id
  vpc_id      = module.vpc2.vpc_id
  peer_region = var.region
  tags = {
    Name = "vpc-peering"
  }
}

resource "aws_vpc_peering_connection_accepter" "this" {
  vpc_peering_connection_id = aws_vpc_peering_connection.this.id # 수락할 VPC Peering 연결 ID
  auto_accept = true
}

resource "aws_route" "vpc1_to_vpc2_route1" {
  route_table_id            = module.vpc1.private_route_table_ids[0] # VPC1의 프라이빗 라우팅 테이블 ID
  destination_cidr_block    = module.vpc2.vpc_cidr_block # VPC2의 CIDR 블록
  vpc_peering_connection_id = aws_vpc_peering_connection.this.id # VPC 피어링 연결 ID
}

resource "aws_route" "vpc1_to_vpc2_route2" {
  route_table_id            = module.vpc1.public_route_table_ids[0]
  destination_cidr_block    = module.vpc2.vpc_cidr_block # VPC2의 CIDR 블록
  vpc_peering_connection_id = aws_vpc_peering_connection.this.id # VPC 피어링 연결 ID
}

resource "aws_route" "vpc2_to_vpc1" {
  route_table_id            = module.vpc2.private_route_table_ids[0] # VPC2의 프라이빗 라우팅 테이블 ID
  destination_cidr_block    = module.vpc1.vpc_cidr_block # VPC1의 CIDR 블록
  vpc_peering_connection_id = aws_vpc_peering_connection.this.id # VPC 피어링 연결 ID

}





resource "aws_ebs_volume" "eks-vol1" {
  availability_zone = "ap-northeast-2a"
  size              = 40

  tags = {
    Name = "eks-vol1-a"
  }
}

resource "aws_ebs_volume" "eks-vol2" {
  availability_zone = "ap-northeast-2b"
  size              = 40

  tags = {
    Name = "eks-vol2-b"
  }
}

resource "aws_ebs_volume" "eks-vol3" {
  availability_zone = "ap-northeast-2c"
  size              = 40

  tags = {
    Name = "eks-vol3-c"
  }
}

resource "aws_ebs_volume" "eks-vol4" {
  availability_zone = "ap-northeast-2a"
  size              = 40

  tags = {
    Name = "eks-vol4-a"
  }
}

resource "aws_ebs_volume" "eks-vol5" {
  availability_zone = "ap-northeast-2b"
  size              = 40

  tags = {
    Name = "eks-vol5-b"
  }
}

resource "aws_ebs_volume" "eks-vol6" {
  availability_zone = "ap-northeast-2c"
  size              = 40

  tags = {
    Name = "eks-vol6-c"
  }
}


module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "19.5.1"

  cluster_name    = local.cluster_name
  cluster_version = "1.24"

  vpc_id                         = module.vpc1.vpc_id
  subnet_ids                     = module.vpc1.private_subnets
  cluster_endpoint_public_access = true

  eks_managed_node_group_defaults = {
    ami_type = "AL2_x86_64"

  }

  eks_managed_node_groups = {
    one = {
      name = "eks-5inque"

      instance_types = ["t3.medium"]

      min_size     = 3
      max_size     = 6
      desired_size = 3

      block_device_mappings = [
        {
          device_name = "/dev/xvdf"
          ebs = {
            volume_size = 50
            volume_type = "gp2"
          }
        },
        {
          device_name = "/dev/xvdg"
          ebs = {
            volume_size = 50
            volume_type = "gp2"
          }
        },
        {
          device_name = "/dev/xvdh"
          ebs = {
            volume_size = 50
            volume_type = "gp2"
          }
        }
      ]
    }
  }
}


# https://aws.amazon.com/blogs/containers/amazon-ebs-csi-driver-is-now-generally-available-in-amazon-eks-add-ons/
data "aws_iam_policy" "ebs_csi_policy" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}

module "irsa-ebs-csi" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version = "4.7.0"

  create_role                   = true
  role_name                     = "AmazonEKSTFEBSCSIRole-${module.eks.cluster_name}"
  provider_url                  = module.eks.oidc_provider
  role_policy_arns              = [data.aws_iam_policy.ebs_csi_policy.arn]
  oidc_fully_qualified_subjects = ["system:serviceaccount:kube-system:ebs-csi-controller-sa"]
}

resource "aws_eks_addon" "ebs-csi" {
  cluster_name             = module.eks.cluster_name
  addon_name               = "aws-ebs-csi-driver"
  addon_version            = "v1.5.2-eksbuild.1"
  service_account_role_arn = module.irsa-ebs-csi.iam_role_arn
  tags = {
    "eks_addon" = "ebs-csi"
    "terraform" = "true"
  }
}
