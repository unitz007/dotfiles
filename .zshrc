# Charles Dinneya's .zshrc

# Aliases
# Replaced unsafe rmDir alias with safe rmdir function

# Git functions
function commit() {
    # Validate input
    if [[ -z "$1" ]]; then
        echo "Error: Commit message is required"
        return 1
    fi
    
    # Add all changes and commit with message
    git add .
    git commit -m "$1"
}

# Safe directory removal function
function rmdir_safe() {
    # Validate input
    if [[ -z "$1" ]]; then
        echo "Error: Directory path is required"
        return 1
    fi
    
    # Check if argument is a valid directory
    if [[ ! -d "$1" ]]; then
        echo "Error: '$1' is not a valid directory"
        return 1
    fi
    
    # Confirm before deletion
    echo "Are you sure you want to remove '$1'? (y/N)"
    read -r response
    if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
        rm -rf "$1"
        echo "Directory '$1' removed successfully"
    else
        echo "Operation cancelled"
    fi
}

# Cloud functions
function deploy() {
    echo "Deploying to cloud..."
}

# Aesthetic configuration
export PS1="%n@%m:%~%# "