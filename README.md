# project-terraform
![Untitled](https://s3-us-west-2.amazonaws.com/secure.notion-static.com/ca7f1c92-2a72-4d31-8944-087cf6078786/Untitled.png)

# region = ap-northeast-2
# vpc = 2 (10.0.0.0/16, 172.30.0.0/24)
# subnet = vpc1: private3, public3 // vpc2: private2, public2
# vpc peering = route table added
# ebs = az a,b,c, 50g X 2
# eks = cluster version 1.24, located vpc1 private, min 3, max 6, desired 3, storage: each node, root 20gb , added 50gb X 3
# eks ebs-csi
