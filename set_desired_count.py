import boto3
import os

# Lambda function to change the desirred capacity of of a node group in an EKS cluster
def lambda_handler(event, context):

    #Get environment variables for the EKS cluster and region
    eks_region = os.environ['REGION']
    eks_cluster_name = os.environ['CLUSTER']

    eks = boto3.client('eks', region_name=eks_region)

    # Get the first node group
    eks_nodegroups = eks.list_nodegroups(
        clusterName=eks_cluster_name
    )

    #Get the node group name
    eks_nodegroup_name = eks_nodegroups['nodegroups'][0]

    #Describe the node group
    response = eks.describe_nodegroup(
        clusterName=eks_cluster_name,
        nodegroupName=eks_nodegroup_name
    )

    #Get the desired, minimum and maximum size of the node group
    desired_size = response['nodegroup']['scalingConfig']['desiredSize']
    minimum_size = response['nodegroup']['scalingConfig']['minSize']
    maximum_size = response['nodegroup']['scalingConfig']['maxSize']

    print('Current Nodegroup Configuration for',eks_nodegroup_name)
    print('---------------------------------------------\n')
    print('DesiredSize',desired_size)
    print('MinSize',minimum_size)
    print('MaxSize',maximum_size)
    print('---------------------------------------------\n')

    #If the desired size is less than 3, scale up the node group to a desired size of 3
    if int(desired_size) < 3:
        eks.update_nodegroup_config(
            clusterName=eks_cluster_name,
            nodegroupName=eks_nodegroup_name,
            scalingConfig={
                'minSize': 0,
                'maxSize': 3,
                'desiredSize': 3
            }
        )
        print('Scaling up the node group to a desired size of 3')
    else:
        print('Node group is already scaled up')

