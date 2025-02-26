#!/bin/bash

:<<'comment'
this script is my version of production backup rotation

this script needs data(/home/ubuntu/bundle/gitPractice/data) folder which contains file1.txt file2.txt file3.txt file4.txt
and empty backups folder(/home/ubuntu/bundle/gitPractice/backups)
comment

#set -x
display_usage(){

	echo "Please provide input parameters as : ./backup_rotation.sh <path_to_src> <path_to_backup>"
}

if [[ $# -eq 0 ]]; then
        display_usage
	exit 1
fi

src_path=$1
backup_path=$2
timestamp=$(date '+%Y-%m-%d-%H-%M-%S')

create_backup(){

	#zip -r <archive.zip> <dir_name> 
	
	zip -r "${backup_path}/backup_${timestamp}.zip" "${src_path}" > /dev/null

	if [[ $? -eq 0 ]]; then
		echo "backup created successfully..."
	else
		echo "Error creating backup.."
		exit 1
	fi
}

perform_rotation(){

	echo "Performing rotation for 5 days"
	list_of_backups=($(ls -t ${backup_path}/backup_*.zip)) 

	#echo "Length of list : ${#list_of_backups[@]}"


	if [[ ${#list_of_backups[@]} -gt 5 ]]; then
		#list slicing ${list[@]:5} ; index starts from 0
		#backup_to_remove=${list_of_backups[@}:5 is incorrect because
		# ("" ,"", "") must be used i mean 
		# (),"" for array initialization in shell script

		backup_to_remove=("${list_of_backups[@]:5}")

		for each_file in "${backup_to_remove[@]}"
		do
			rm -f "$each_file"
		done

	fi

	#echo "List is.."
	#echo "${list_of_backups[@]}" -- prints 6 because list of backups is not updated after rotation

}


main(){
	create_backup
	perform_rotation
}

main
