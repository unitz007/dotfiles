# fish config

# aliases
alias g='git'
alias mci='mvn clean install'
alias mcp='mvn clean package'
alias bootRun='mvn spring-boot:run'

# functions
function commit
        if test (count $argv) -lt 1
                printf "Error: missing commit message"
        else
                g add .
                g commit -m $argv[1]
                g push origin master
end