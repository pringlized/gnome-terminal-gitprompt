# Needs patched fonts to work: https://github.com/powerline/fonts

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/git.sh
source ${DIR}/services.sh
source ${DIR}/main.sh

set_bash_prompt() {
    arrow_icon=$'\uE0B0'
    local next_color=''

    # check if git repo exists, determine color
    local git="\$(load_git)"
    local path="$(load_path $next_color)"  
    local userhost="$(load_userhost)"
    local services="\$(load_services)"
    local prompt="$(load_prompt)" 

    # display 
    
    #export PS1="\n${services}\u${userhost}${path}${git}${prompt}"
    #export PS1="\\[\n${services}${userhost}${path}${git}${prompt}"
    export PS1="\n${services}${userhost}${path}${git}${prompt}"
}