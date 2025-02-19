#!/bin/bash

set -x


<<task
shubham create_ec2_instance
task

# function to check if aws cli is installed
check_awscli(){
        if ! command -v aws &> /dev/null ; then
                echo "AWS CLI is not installed .. Please install it" >&2
        fi
}


#function to install aws cli if not
install_awscli(){
        echo "Installing AWS CLI version v2..."

        curl -s curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
        sudo apt-get install -y unzip &> /dev/null
        unzip -q awscliv2.zip
        sudo ./aws/install

        # verify aws is installed
        aws --version >&2

        #clean up
        rm -rf awscliv2.zip ./aws
}


#wait till instance to be in running state
wait_for_running(){

        local instance_id="$1"
        echo "waiting for "$instance_id" to be in running state"

        while true;do
                state=$(aws ec2 describe-instances \
                               --instance-ids "$instance_id" \
                               --query "Reservations[0].Instances['$instance_id'].State.Name" \
                               --output text)
                if [[ $state == 'running' ]];then
                        echo "Instance $instance_id is now running.."
                        break
                fi
                sleep 10
        done
}

#function to create aws ec2 instance
create_ec2_instance(){
	
        local ami_id="$1"
        local instance_type="$2"
        local key_name="$3"
        local subnet_id="$4"
        local security_group_ids="$5"
        local instance_name="$6"

        #aws cli command for create ec2 instance
        instance_id=$(aws ec2 run-instances \
                --image-id $ami_id \
                --instance-type $instance_type \
                --key-name $key_name \
                --subnet-id $subnet_id \
                --security-group-ids $security_group_ids \
                --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$instance_name}]" \
                --query 'Instances[0].InstanceId' \
                --output text)

	echo "Instance id is : $instance_id"

  if [[ -z "$instance_id" ]]; then
                echo "Failed to create ec2 instance.." >&2
                exit 1
        fi

        echo "Instance "$instance_id" created successfully"

        #wait for instance till in running state
        wait_for_running "$instance_id"
}


main(){

#       check_awscli || install_awscli

        if ! check_awscli; then
                install_awscli || exit 1
        fi
        # parameters for creating EC2 instances
	 AMI_ID="ami-04b4f1a9cf54c11d0"
        INSTANCE_TYPE="t2.micro"
        KEY_NAME="Test11"
        SUBNET_ID="subnet-0d465a0344c9a341f"
        SECURITY_GROUP_IDS="sg-064dbe32c71021768"
        INSTANCE_NAME="Shell_script_ec2_demo"

        # creating ec2 instance through aws cli
        create_ec2_instance "$AMI_ID" "$INSTANCE_TYPE" "$KEY_NAME" "$SUBNET_ID" "$SECURITY_GROUP_IDS" "$INSTANCE_NAME"

        echo "EC2 instace creation completed"
}
# pass arguments as it is
main "$@"


