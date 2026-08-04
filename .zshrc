# Charles Dinneya's .zshrc

# Aliases
alias rmDir="rm -rf"

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