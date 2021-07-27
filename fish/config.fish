# fish shell  configurations

# set fish greeting message

function _greetings_
	set hour (eval 'date +"%H"') # gets time hour
	if test $hour -lt 12
		set fish_greeting "Welcome $USER, Good Morning."
	else if test $hour -lt 16 -a $hour -ge 12
		set fish_greeting "Welcome $USER, Good Afternoon."
	else if test $hour -lt 23 -a $hour -ge 16
		set fish_greeting "Welcome $USER, Good Evening."
	end
end

# greeting message
_greetings_

# aliases
# navigation aliases
alias ..='cd ..'
alias home='cd --'

# maven aliases
# alias install='mvn clean install -DskipTests'
alias build='mvn clean package -DskipTests'
alias assert='mvn test'
alias run='mvn spring-boot:run'
alias clean='mvn clean'

# docker/docker-compose alias
alias db='docker build'
alias dc='docker-compose'

# git aliases
alias g='git'
# alias gp='git push'
alias gi='git init'
alias gr='git remote'
alias pull='git pull'

function commit
	if test (count $argv) -lt 1
		echo "Error: missing 'commit message'"
		echo "Usage: commit <commit message>"
	else
		g add .
		git commit -m $argv[1]
		# gpom
	end
end

function push
	if test (count $argv) -lt 1
		echo "Error: missing 'commit message'"
		echo "Usage: push <commit message>"
	else
		g add .
		git commit -m $argv[1]
		git push
	end
end

# apt alias
alias install='sudo apt install'
alias update='sudo apt update'
alias upgrade='sudo apt upgrade'
alias remove='sudo apt remove'
alias autoremove='sudo apt autoremove'
alias autoclean='sudo apt autoclean'
alias purge='sudo apt purge --autoremove'

# source config.fish.local
if test -f $HOME/.config/fish/config.local.fish
	. $HOME/.config/fish/config.local.fish
end
