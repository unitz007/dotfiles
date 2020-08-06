# fish shell  configurations

# set fish greeting message

function _greetings_
	set hour (eval 'date +"%H"') # gets time hour
	if test $hour -eq 0 -a $hour -lt 12
		set fish_greeting "Welcome $USER, Good Morning."
	else if test $hour -eq 12 -a $hour -lt 16
		set fish_greeting "Welcome $USER, Good Afternoon."
	else
		set fish_greeting "Welcome $USER, Good Evening."
	end
end

# call function
_greetings_

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

