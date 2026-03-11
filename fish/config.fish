# ~/.config/fish/config.fish
# Basic Fish shell configuration

# Set a friendly prompt
function fish_prompt
    set_color cyan
    echo -n (prompt_pwd) ' '
    set_color normal
end

# Enable vi mode (optional)
# fish_vi_key_bindings

# Load any plugins if fish_plugins file exists
if test -f (dirname (status --current-filename))/fish_plugins
    source (dirname (status --current-filename))/fish_plugins
end