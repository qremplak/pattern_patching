#!/bin/bash

# Global variable
SPLIT_TOKEN="\n========================================\n"

# Check if a directory is specified as an argument
if [ $# -eq 0 ]; then
    echo "Usage: $0 <directory>"
    exit 1
fi

# Directory passed as argument
directory=$1

# Ensure that the directory exists
if [ ! -d "$directory" ]; then
    echo "Error: The specified directory does not exist."
    exit 1
fi

# Iterate over patches files in the directory
for file in "$directory"/*; do
    if [ -f "$file" ]; then
        echo "Processing file: $file"

        awk -v RS="$SPLIT_TOKEN" '{print > "split_file_" NR}' $file
        #split_file_1 > action
        action=$(cat split_file_1)
        #split_file_2 > target_file
        target_file=$(cat split_file_2)
        #split_file_3 > pattern
        #split_file_4 > content

        echo "action" $action
        echo "target_file" $target_file

        # Process the variables based on the action
        case $action in
            "inject_after")
                echo "Injecting content into target file: $target_file"
                # add after
                sed -i -e "/$(sed 's:[][\/.^$*]:\\&:g' split_file_3)/r split_file_4" $target_file

                ;;
            "inject_before")
                echo "Injecting content into target file: $target_file"
                # add before
                # use replace but add pattern to the end of content
                cat split_file_3 >> split_file_4
                sed -i -e "/$(sed 's:[][\/.^$*]:\\&:g' split_file_3)/{" -e "r split_file_4" -e "d" -e "}" $target_file
                ;;
            "replace_line")
                echo "Replacing line containing pattern with content in target file: $target_file"
                # replace line
                sed -i -e "/$(sed 's:[][\/.^$*]:\\&:g' split_file_3)/{" -e "r split_file_4" -e "d" -e "}" $target_file
                ;;
            "replace")
                echo "Replacing pattern with content in target file: $target_file"
                # replace
                sed -i -e "s/$(sed 's:[][\/.^$*]:\\&:g' split_file_3)/$(<split_file_4 sed -e 's/[\&/]/\\&/g' -e 's/$/\\n/' | tr -d '\n')/g" -i $target_file
                ;;
            *)
                echo "Action $action not recognized. No specific treatment applied."
                ;;
        esac

        rm split_file_1 split_file_2 split_file_3 split_file_4
        
    fi
done

echo "Done."
