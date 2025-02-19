#!/bin/bash

<< comment
this is practice script for creating ec2 instance
comment

#function to check if aws is installed
#command -v aws = returns path if exists ; similar to type builtin
#command aws --version = executable whereas above is not ; it checks if aws in in path /usr/local/bin/aws
check_aws(){

	if ! command -v aws &> /dev/null; then
		echo "AWS is not Installed..Make sure aws is.." >&2
		install_aws
		exit 1
	else
		echo "AWS is already installed"
		return 0
	fi
}

#function to install aws 
install_aws(){

	echo "Downloading aws cli.."
	
	if ! curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" &> /dev/null; then
		echo "Failed to download aws cli"
		exit 1
	fi

	echo "unzipping aws cli.."
	if ! unzip -q awscliv2.zip; then
		echo "Failed to unzip aws cli"
		rm -f awscliv2.zip #-f = force removal if awscliv2.zip doesnt exist
		exit 1
	fi

	echo "Installing aws cli.."
	if ! sudo ./aws/install; then
		echo "Failed to install aws cli.."
		rm -r aws
		rm -f awscliv2.zip
		exit 1
	fi

	#clean up
		rm -r aws
		rm awscliv2.zip

	echo "AWS cli installed successfully.."
}

wait_for_running(){

	 echo "checking for instance to be in running state.."
	 instance_id=$1
	 instance_state="pending"
	 while [ "$instance_state" != "running" ];
	 do
	 instance_state=$(aws ec2 describe-instances \
		 --instance-ids "$instance_id" \
	 	 --query 'Reservations[*].Instances[*].State.Name' \
		 --output text)
	 
	 if [[ -z "$instance_state" ]];then
		 echo "Failed to run instance"
		 exit 1
	 fi

	 echo "Current state is : $instance_state"
	 sleep 10
	 done

	 echo "Instance $instance_id is now running.."

}

create_ec2_instance(){
	 
	image_id=$1
	instance_type=$2
	key_pair=$3
	subnet_id=$4
	security_group_id=$5
	instance_name=$6

	instance_id=$(aws ec2 run-instances \
		--image-id "$image_id" \
		--instance-type "$instance_type" \
		--key-name "$key_pair" \
		--subnet-id "$subnet_id" \
		--security-group-ids "$security_group_id" \
		--tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$instance_name}]" \
		--query "Instances[0].InstanceId" \
		--output text)

	if [[ -z $instance_id ]]; then
		echo "EC2 instance not created successfully"
		exit 1
	else
		echo "Instance $instance_id  created successfully"
		wait_for_running "$instance_id"
	fi


}

main(){

	IMAGE_ID="ami-053a45fff0a704a47"
	INSTANCE_TYPE="t2.micro"
	KEY_PAIR="Test11"
	SUBNET_ID="subnet-0d465a0344c9a341f"
	SECURITY_GROUP_ID="sg-064dbe32c71021768"
	INSTANCE_NAME="shell_script_ec2_demo"
	
if ! check_aws; then
	install_aws
fi
	#creating aws ec2 instance through aws cli
	create_ec2_instance "$IMAGE_ID" "$INSTANCE_TYPE" "$KEY_PAIR" "$SUBNET_ID" "$SECURITY_GROUP_ID" "$INSTANCE_NAME"

	#echo "EC2 instance created successfully"


}

main 
