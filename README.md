# project-terraform
![terraformvpc](https://github.com/songmozzi/project-terraform/assets/110387825/2e254cb1-cc18-4647-832c-212c2e74041a)

# region = ap-northeast-2
# vpc = 2 (10.0.0.0/16, 172.30.0.0/24)
# subnet = vpc1: private3, public3 // vpc2: private2, public2
# vpc peering = route table added
# ebs = az a,b,c, 50g X 2
# eks = cluster version 1.24, located vpc1 private, min 3, max 6, desired 3, storage: each node, root 20gb , added 50gb X 3
# eks ebs-csi
