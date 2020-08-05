# mvn aliases
alias bootRun="mvn spring-boot:run"

# apt aliases
alias update="sudo apt update"

# git aliases

# git add, commit and push
function commit() {
    message=$1
    if [ -z "$message" ]
    then
        echo "Error: empty commit message"
    else
        git add . && git commit -m $1 && git push origin master
    fi
}

