# This file is sourced by all interactive shells on startup, including some that are not login shells.
if [ -f ~/.env ]; then
    source ~/.env
    source ~/.help
    source ~/.proxy
    source ~/.helpers
fi
# Function to process the path
process_path() {
    # Get the Windows path as the first argument
    local win_path="$1"
    
    # Use cygpath to convert the Windows path to POSIX path
    local posix_path=$(cygpath -u "$win_path")
    
    # Replace spaces with '\ '
    local modified_path="${posix_path// /\\ }"
    
    # Output the modified path
    echo "$modified_path"
}
export_pod_name() {
    export search_term="$1"  # The term to search for in the pod names
    #print search term
    echo "search term is $search_term"
    # Use kubectl to get the list of pod names and filter them by the search term
    export pod_name=$(kubectl get pods --no-headers -o custom-columns=":metadata.name" | grep "$search_term" | head -n 1)
    #print pod name
    echo "pod name is $pod_name"
    # Check if we found a matching pod
    if [ -z "$pod_name" ]; then
        echo "No pod found matching the search term '$search_term'."
        return 1  # Return failure status if no pod was found
    fi

    # Export the pod name as an environment variable
    export POD_NAME="$pod_name"
    echo "Exported POD_NAME=$POD_NAME"
}
#kubectl port forward with first matched pod name
pf(){
    # local search_term="$1"
    export_pod_name "$1"
    kubectl port-forward $POD_NAME 5431:5432 -n tq-contract # from https://github.com/telus/cdo-contractqc-api/blob/main/docs/kubectl_googleSDK.txt#L43
}


#set gcp project from search pattern
setgcp() {
    unset GCLOUD_PROJECT_ID
    local search_term="$1"
        if [ -z "$search_term" ]; then
        echo "No search term provided. Listing all projects."
        gcloud projects list
        else
        echo "Searching for project with name matching '$search_term'."
        local project_ids=$(gcloud projects list --format="value(projectId)" --filter="name~$search_term")
        local project_count=$(echo "$project_ids" | wc -l)
        if [ "$project_count" -gt 1 ]; then
            echo "Multiple projects found matching the search term '$search_term':"
            echo "$project_ids"
            return 0  # Return without setting the project, as multiple matches were found
        else
            # If only one project is found, set it as the active project
            export GCLOUD_PROJECT_ID="$project_ids"
            echo "Exported GCLOUD_PROJECT_ID='$GCLOUD_PROJECT_ID'"
        fi
            # Ensure the project ID is set from export_gcloud_project
        if [ -z "$GCLOUD_PROJECT_ID" ]; then
            echo "No GCP project ID set."
            return 1
        fi
        # Set the project in gcloud
        gcloud config set project "$GCLOUD_PROJECT_ID"
        echo "Set GCP project to '$GCLOUD_PROJECT_ID'"
    fi
}

getgcpsecrets(){
    gcloud secrets list
    echo " run gcloud secrets versions access latest --secret=$1"

}

# Function to change directory to a project folder based on a pattern
cdg() {
    local search_path="$HOME/Documents/github"
    local pattern="$1"
    
    if [ -z "$pattern" ]; then
        echo "Usage: cdp <project-name-pattern>"
        return 1
    fi
    
    local matches=$(find "$search_path" -maxdepth 1 -type d -name "*${pattern}*")
    local count=$(echo "$matches" | grep -v "^$" | wc -l)
    
    if [ $count -eq 0 ]; then
        echo "No matching projects found for: $pattern"
        return 1
    elif [ $count -eq 1 ]; then
        cd "$matches"
        echo "Changed to $(pwd)"
    else
        echo "Multiple matches found:"
        echo "$matches" | sed "s|$search_path/||"
        first_match=$(echo "$matches" | head -n 1)
        cd "$first_match"
        echo "Defaulting to: $(pwd)"
    fi

}
# Function to code a project folder based on a pattern
codeg() {
    local search_path="$HOME/Documents/github"
    local pattern="$1"
    
    if [ -z "$pattern" ]; then
        echo "Usage: cdp <project-name-pattern>"
        return 1
    fi
    
    local matches=$(find "$search_path" -maxdepth 1 -type d -name "*${pattern}*")
    local count=$(echo "$matches" | grep -v "^$" | wc -l)
    
    if [ $count -eq 0 ]; then
        echo "No matching projects found for: $pattern"
        return 1
    elif [ $count -eq 1 ]; then
        code "$matches"
        echo "Changed to $(pwd)"
    else
        echo "Multiple matches found:"
        echo "$matches" | sed "s|$search_path/||"
        first_match=$(echo "$matches" | head -n 1)
        code "$first_match"
        echo "Defaulting to: $(pwd)"
    fi

}
# Functions to simplify git commands
add(){
    git add "$1"
}
commit(){
    git commit -m "$1"
}
push(){
    git push
}
pull(){
    git pull
}
clone() {
    echo "gitc"
    # Check if a URL or repository name is provided
    if [ -z "$1" ]; then
        echo "Usage: clone <github_repo_url_or_name>"
        return 1
    fi
    cd ~/Documents/github/
    git clone "$1"

    # Get the name of the last created directory (the repo folder)
    repo_name=$(basename "$1" .git)
    cd "$repo_name" || return 1
}
addcommitpush(){
    git add .
    git commit -m "$1"
    git push
}
# Function to query OpenAI-compatible API
ai() {
    # Check if required environment variables are set
    if [ -z "$OPENAI_API_BASE_URL" ] || [ -z "$OPENAI_API_KEY" ] || [ -z "$OPENAI_MODEL_ID" ]; then
        echo "Error: Required environment variables not set."
        echo "Please set:"
        echo "OPENAI_API_BASE_URL: $OPENAI_API_BASE_URL  (e.g., https://api.openai.com/v1)"
        echo "OPENAI_API_KEY: $OPENAI_API_KEY       (your API key)"
        echo "OPENAI_MODEL_ID: $OPENAI_MODEL_ID      (e.g., gpt-4-turbo-preview)"
        return 1
    fi

    # Get user input or use argument if provided
    local prompt
    if [ -n "$1" ]; then
        prompt="$*"
    else
        echo "Enter your prompt (Ctrl+D when done):"
        prompt=$(cat)
    fi

    # Prepare the API request
    local data="{
        \"model\": \"$OPENAI_MODEL_ID\",
        \"messages\": [
            {\"role\": \"system\", \"content\": \"$OPENAI_SYSTEM_PROMPT\"},
            {\"role\": \"user\", \"content\": \"$prompt\"}
        ]
    }"

    # Make the API request
    curl -s -X POST "$OPENAI_API_BASE_URL/chat/completions" \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer $OPENAI_API_KEY" \
        -d "$data" | jq -r '.choices[0].message.content'
}
# cli(){
#     export OPENAI_SYSTEM_PROMPT="You are a command line assistant you translate user natural language commands to bash commands. output only the bash command"
#     ai "What is the command to $1?"
# }
cli() {
    local auto_yes=false
    local auto_no=false
    local command_text=""

    # Parse arguments for -y or -n flags
    while [[ $# -gt 0 ]]; do
        case $1 in
            -y)
                auto_yes=true
                shift
                ;;
            -n)
                auto_no=true
                shift
                ;;
            *)
                if [ -z "$command_text" ]; then
                    command_text="$1"
                else
                    command_text="$command_text $1"
                fi
                shift
                ;;
        esac
    done

    # Set the system prompt for command translation
    export OPENAI_SYSTEM_PROMPT="You are a command line assistant. Translate natural language to bash commands. Output only the bash command, no explanations."

    local command=$(ai "$command_text")

    echo -e "\nProposed command:\n$command"

    # Handle automatic execution based on flags
    if [ "$auto_yes" = true ]; then
        echo "Auto-executing command (-y flag)..."
        eval "$command"
        return
    elif [ "$auto_no" = true ]; then
        echo "Command not executed (-n flag)"
        return
    fi

    # If no flags, ask for confirmation
    read -p "Execute this command? [y/N] " -n 1 -r
    echo
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "Executing command..."
        eval "$command"
    else
        echo "Command not executed"
    fi
}

weather
