# fish config

# set fish shell look
set fish_greeting \x1d

# aliases

# navigation aliases
alias ..='cd ..'
alias home='cd --'

# maven aliases
alias mci='mvn clean install'
alias mcp='mvn clean package'
alias bootRun='mvn spring-boot:run'

# git aliases
alias g='git'
alias gpom='git push origin master'
function commit
	if test (count $argv) -lt 1
		echo "Error: missing 'commit message'"
		echo "Usage: commit <commit message>"
	else
		g add .
		git commit -m $argv[1]
		gpom
	end
end