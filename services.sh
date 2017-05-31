get_service_icon() {
    # check input
    if [ $# -eq 0 ] || [ -z "$1" ] ; then
        echo ''
    else
        local service=$1
        declare -A icons=(
            [docker]="\ue7b0"
            [postgresql]='\ue76e'
            [mariadb]='\ue704'
            [mysqld]='\ue704'
        )
        echo ${icons[$service]}
    fi
}

check_services() {
    #echo "check input: $1"
    # check input
    if [ $# -eq 0 ] || [ -z "$1" ] ; then
        echo false
    else
        local service=$1
        local is_running=false
        local running_services=$(systemctl list-units -t service --no-pager --no-legend | grep active | grep -v systemd | grep -v exited | awk '{ print $1 }')
        local service_running=$(echo $running_services | grep -o $service)
        if [[ "$service_running" == $service ]]; then is_running=true; fi

        echo $is_running
    fi
}

check_load() {
    local load=$(uptime | grep -ohe 'load average[s:][: ].*' | awk '{ print $3 }' | sed -e "s/,//")
    echo $load
}

load_services() {
    local services_colors="\001\033[30;107m\002" # black;white-30;107
    local load_white="\001\033[30;107m\002"
    local load_yellow="\001\033[30;43m\002"
    local load_red="\001\033[30;41m\002"
    local right_block_colors="\001\033[97;44m\002" # white;blue-97;44m
    local right_block_white="\001\033[97;44m\002"
    local right_block_yellow="\001\033[33;44m\002"
    local right_block_red="\001\033[31;44m\002" 
    local right_block="\ue0b0" #\ue0b0   
    local reset="\001\033[0m\002"
    local services_prompt=''
    declare -a services=("docker" "postgresql" "mariadb" "mysqld")

    # determine background based on load
    local load="$(check_load)"
    if (( $(echo "$load < 1.3" | bc -l) )); then
        services_colors=$load_white
        right_block_colors=$right_block_white
    elif (( $(echo "$load < 2.0" | bc -l) )); then
        services_colors=$load_yellow
        right_block_colors=$right_block_yellow
        #use flames
        right_block="\ue0c0"        
    else
        services_colors=$load_red
        right_block_colors=$right_block_red
        # use flames
        right_block="\ue0c0"
    fi

    # iterate over services we are watching
    for (( i=0; i<${#services[@]}+1; i++ )); 
    do
        #echo "service: ${services[$i]}"
        service_running="$(check_services ${services[$i]})"
        #echo "is running: $service_running"

        if [ "$service_running" = true ]; then
            icon="$(get_service_icon ${services[$i]})"
            # add to services_prompt variable 
            #echo "is_running: $service_running"
            services_prompt+=" $icon"
        fi 
    done 
    #echo "Prompt: $services_prompt"

    if [[ -z "$services_prompt" ]]; then
        echo -e "$right_block_colors$right_block${reset}"
    else
        echo -e "$services_colors$services_prompt  $right_block_colors$right_block${reset}"
    fi 
    #echo -e "$services_colors\ue76e \ue704 \ue7b0 $right_block_colors$right_block${reset}"
}
