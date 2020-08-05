# fish config

# aliases
alias g='git'
alias mci='mvn clean install'
alias mcp='mvn clean package'
alias bootRun='mvn spring-boot:run'
alias gpom='git push origin master'

# functions
function commit
        if test (count $argv) -lt 1
                echo "Error: missing commit message"
        else
                g add .
                git commit -m $argv[1]
                gpom
        end
end