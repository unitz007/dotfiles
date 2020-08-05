# fish shell configuration
# place file in ~/.config/fish

# aliases
alias g='git'
alias mci='mvn clean install'
alias mcp='mvn clean package'
alias bootRun='mvn spring-boot:run'
alias gpom='git push origin master'

# set git add, commit and push
function commit
        if test (count $argv) -lt 1
                echo "Error: 'missing commit message'"
                echo "Usage: commit <commit message>"
        else
                g add .
                git commit -m $argv[1]
                gpom
        end
end