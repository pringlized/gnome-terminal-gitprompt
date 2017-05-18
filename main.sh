load_userhost() {
    local colors="\001\033[97;44m\002"
    local arrow_colors="\001\033[34;100m\002"    
    local arrow_icon=$'\uE0B0'
    local reset="\001\033[0m\002"

    echo -e "${colors} \u@\h $arrow_colors${arrow_icon}$reset" 
}

load_path() {
    # check input
    if [ $# -eq 0 ] || [ -z "$1" ] ; then
        local arrow_colors="\001\033[90;49m\002" 
    else
        local next_color=$1    
        local arrow_colors="\001\033[90;\002\001${next_color}m\002"
    fi

    local colors="\001\033[97;100m\002"  
    local arrow_icon=$'\uE0B0'
    local reset="\001\033[0m\002"

    echo -e "$colors \w $reset"
}

load_prompt() {
    local colors="\001\033[97;49m\002"
    local arrow_colors="\001\033[90;49m\002"
    local arrow_icon=$'\uE0B0'
    local reset="\001\033[0m\002"
    echo -e "$reset\n $colorsλ "         
}