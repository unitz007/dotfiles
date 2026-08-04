# Charles Dinneya's .zshrc

# Aliases
# Convert rmDir alias to a safer function
rmDir() {
    if [[ $# -eq 0 ]]; then
        echo "Usage: rmDir <directory>"
        return 1
    fi
    
    local dir="$1"
    if [[ ! -d "$dir" ]]; then
        echo "Error: '$dir' is not a directory"
        return 1
    fi
    
    echo "Are you sure you want to remove '$dir'? [y/N]"
    read -q confirmation
    echo ""
    
    if [[ "$confirmation" =~ ^[Yy]$ ]]; then
        rm -rf "$dir"
        echo "Directory '$dir' removed successfully"
    else
        echo "Operation cancelled"
    fi
}

# Git functions
function commit() {
    git add .
    git commit -m "$1"
}

# Cloud functions
function deploy() {
    echo "Deploying to cloud..."
}

# Aesthetic configuration
export PS1="%n@%m:%~%# "

# Enhanced commit function with standardized indentation
function commit_with_validation() {
    if [[ -z "$1" ]]; then
        echo "Usage: commit_with_validation <message>"
        echo "Please provide a commit message"
        return 1
    fi
    
    echo "Adding all changes and committing with message: $1"
    git add .
    git commit -m "$1"
    
    if [[ $? -eq 0 ]]; then
        echo "Commit successful!"
    else
        echo "Commit failed!"
        return 1
    fi
}