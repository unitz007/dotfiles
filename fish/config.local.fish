# local aliases

# alias to stop service
function stop_services
	bash $HOME/scripts/stop_services
end

# intellij
alias intellij='intellij-idea-community'

# flutter alias
alias fd='flutter doctor'
alias fr='flutter run -v'

# adb aliases
alias adb=/home/charles/snap/androidsdk/current/AndroidSDK/platform-tools/adb
function adb_connect
        adb kill-server
        adb tcpip 5555
        adb connect $argv[1]
end