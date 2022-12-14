#!/bin/bash

####################################################################
# 1Password Cloud Backup                                           #
# backup                                                           #
#                                                                  #
# https://github.com/michael-batz/1password-backup                 #
####################################################################

print_usage()
{
    echo "1Password Cloud Backup"
    echo "usage: $0 -d <output dir>"
    exit 0
}

# define variables
tool_op="op"
tool_jq="jq"
output_dir="."

# parse arguments
while getopts "d:" option
do
    case "${option}" in
        d) output_dir=${OPTARG};;
        *) print_usage     
    esac
done

output_file="${output_dir}/1pass-$(date '+%Y%m%d-%H%M%S').bak"

# signin to 1Password
echo "1Password Cloud Backup"
echo "- signin to 1Password..."
eval $(${tool_op} signin)

# get a list of all items
echo "- get list of all items from 1Password..."
items=$(${tool_op} items list --format=json --cache | ${tool_jq} --raw-output '.[].id')

# get all items from 1Password
output=""
for item in $items
do
    echo "  - get item ${item}..."
    output+=$(${tool_op} items get ${item} --format=json --cache) 
done

# encrypt items and write to output file
echo "- store items in encrypted output file ${output_file}..."
echo $output | gpg -c --no-symkey-cache --batch --passphrase $(${tool_op} read op://Private/1Password\ Account/password) -o "${output_file}"

# signout from 1Password
echo "- signout from 1Password"
${tool_op} signout
