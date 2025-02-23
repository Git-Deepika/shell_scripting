#!/bin/bash
#
#
<<comment
 this script is to list repository collaborators with read access
comment

#set -x 

#export variables for uname and password
git_username=$username
git_token=$token

#Input parameters
#owner = orgnaization name ; repository name
OWNER_NAME=$1
REPO_NAME=$2

github_api_get_url(){

	API_URL="https://api.github.com"
	endpoint="repos/${OWNER_NAME}/${REPO_NAME}/collaborators"
	
	#curl to endpoint 
	#curl -s = silent mode
	#curl -u <uname>:<pwd> <url>
	if ! curl -s -u ${git_username}:${git_token} ${API_URL}/${endpoint} ; then
		echo "Bad response from endpoint"
	fi

}

list_users_with_read_access(){

	#endpoint call
	collaborators_list=$(github_api_get_url | jq '.[] | select(.permissions.read == true) | .login')

	if [[ -z $collaborators_list ]]; then
		echo "No users with read access for $OWNER_NAME:$REPO_NAME.."
	else
		echo "Users with read access.."
		echo $collaborators_list
	fi

}

main(){
	if [[ -z $OWNER_NAME || -z $REPO_NAME ]] ;then
		echo "Incorrect input . Need owner and repo name as parameters.."
	fi

	list_users_with_read_access
}

main


