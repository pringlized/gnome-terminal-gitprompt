function load_git() {
  git_branch=$(git branch --no-color 2>/dev/null | grep \* | sed 's/* //')

  arrow=$'\uE0B0'
  end_bubble=$'\ue0b4'
  arrow_left=$'\uE0B2' 
  git_logo=$'\uf1d3'
  laptop=$'\uf109'

  local current_commit_hash=$(git rev-parse HEAD 2> /dev/null)
  if [[ -n $current_commit_hash ]]; then local is_a_git_repo=true; fi  
  
  if [[ $is_a_git_repo == true ]]; then
    # initialized colors and icons
    local path_arrow="\001\033[90;42m\002"
    local repo_colors="\001\033[30;42m\002"
    local status_arrow_colors="\001\033[32;101m\002"
    local edited_icon="\uf040"
    local untracked_icon="\uf128"
    local deleted_icon="\uf068"
    local staged_icon="\uf067"
    local commit_icon="\uf498"
    #local tracking_icon="\uf407"
    local rebase_icon="\uf407"
    local merge_icon="\uf419"
    local diverged_icon="\uf418"
    local push_icon="\uf40a"
    local tag_icon="\uf02b"
    local fast_forward_icon="\uf102"
    local remote_colors="\001\033[30;101m\002"
    local end_colors="\001\033[91;49m\002"
    local end_icon="\ue0b4"
    
    # initialize all status flags
    local detached=false
    local has_upstream=false
    local commits_diff=0
    local commits_ahead=0
    local commits_behind=0
    local has_modifications=false
    local has_modifications_cached=false
    local has_adds=false
    local has_deletions=false
    local has_deletions_cached=false
    local ready_to_commit=false
    local has_untracked_files=false
    local is_on_a_tag=false    
    local has_diverged=false
    local should_push=false
    local will_rebase=false
    local has_stashed=false
    
    # initialize promt display
    local status=""
    local push_status=""    

    # determine current branch
    local current_branch=$(git rev-parse --abbrev-ref HEAD 2> /dev/null)
    if [[ $current_branch == 'HEAD' ]]; then local detached=true; fi    

    # check upstream
    local upstream=$(git rev-parse --symbolic-full-name --abbrev-ref @{upstream} 2> /dev/null)
    if [[ -n "${upstream}" && "${upstream}" != "@{upstream}" ]]; then local has_upstream=true; fi    
    
    # get status and count for tracked and untracked
    git_status=$(git status --porcelain 2>/dev/null)

    # determine status flags
    if [[ $git_status =~ ($'\n'|^).M ]]; then local has_modifications=true; fi
    if [[ $git_status =~ ($'\n'|^)M ]]; then local has_modifications_cached=true; fi
    if [[ $git_status =~ ($'\n'|^)A ]]; then local has_adds=true; fi
    if [[ $git_status =~ ($'\n'|^).D ]]; then local has_deletions=true; fi
    if [[ $git_status =~ ($'\n'|^)D ]]; then local has_deletions_cached=true; fi
    # NOTE: not working for some reason
    if [[ $git_status =~ ($'\n'|^)[MAD] && ! $git_status =~ ($'\n'|^).[MAD\?] ]]; then ready_to_commit=true; fi   
    # NOTE: this is the hacky fix
    if [ $has_modifications_cached == true ] || [ $has_deletions_cached == true ] || [ $has_adds == true ]; then ready_to_commit=true; fi

    # set untracked status
    local number_of_untracked_files=$(\grep -c "^??" <<< "${git_status}")
    if [[ $number_of_untracked_files -gt 0 ]]; then local has_untracked_files=true; fi

    # tags
    local tag_at_current_commit=$(git describe --exact-match --tags $current_commit_hash 2> /dev/null)
    if [[ -n $tag_at_current_commit ]]; then local is_on_a_tag=true; fi    

    # determine upstream statuses
    if [[ $has_upstream == true ]]; then
        commits_diff="$(git log --pretty=oneline --topo-order --left-right ${current_commit_hash}...${upstream} 2> /dev/null)"
        commits_ahead=$(\grep -c "^<" <<< "$commits_diff")
        commits_behind=$(\grep -c "^>" <<< "$commits_diff")
    fi

    # diverged and should_push statuses
    if [[ $commits_ahead -gt 0 && $commits_behind -gt 0 ]]; then local has_diverged=true; fi
    if [[ $has_diverged == false && $commits_ahead -gt 0 ]]; then local should_push=true; fi   

    # rebase
    local will_rebase=$(git config --get branch.${current_branch}.rebase 2> /dev/null)

    # stashing
    local number_of_stashes="$(git stash list -n1 2> /dev/null | wc -l)"
    if [[ $number_of_stashes -gt 0 ]]; then local has_stashes=true; fi     

    #echo "git_status: $git_status"
    #"""
    #echo ""
    #echo "current_branch: $current_branch"
    #echo "detached: $detached"
    #echo "has_upstream: $has_upstream"
    #echo "commits_diff: $commits_diff"
    #echo "commits_ahead: $commits_ahead"
    #echo "commits_behind: $commits_behind"
    #echo "has_modifications: $has_modifications"
    #echo "has_modifications_cached: $has_modifications_cached"
    #echo "has_adds: $has_adds"
    #echo "has_deletions: $has_deletions"
    #echo "has_deletions_cached: $has_deletions_cached"
    #echo "ready_to_commit: $ready_to_commit"
    #echo "has_untracked_files: $has_untracked_files"
    #echo "has_diverged: $has_diverged"
    #echo "should_push: $should_push"
    #echo "will_rebase: $will_rebase"
    #echo "has_stashed: $has_stashed"
    #"""

    # TODO
    # check stashed 


    # check untracked
    if [[ "$has_untracked_files" == true ]]; then
        status+=" $untracked_icon"
    fi
    # check deleted
    if [[ $has_deletions == true ]]; then
        status+=" $deleted_icon"
    fi
    # check unstaged
    if [[ $has_modifications == true ]]; then
        status+=" $edited_icon"
    fi
    # check added
    if [[ $has_adds == true ]]; then
        status+=" $staged_icon"
    fi
    # check staged
    if [[ $ready_to_commit == true ]]; then
        status+=" $commit_icon"
    fi

    # diverged or should push?
    # TODO: ADD FAST FORWARD!! Means local repo is behind upstream but NOT ahead
    #has_diverged=true
    if [[ $has_diverged == true ]]; then
        push_status="$diverged_icon"
    elif [[ $should_push == true ]]; then
        push_status="$push_icon"
    else
        push_status="$laptop"
    fi

    # commits behind
    if [[ $commits_behind -gt 0 ]]; then
        # hack to fix spacing with icons
        local dcb="-${commits_behind}"
    else
        local dcb="--"
    fi

    # commits ahead
    if [[ $commits_ahead -gt 0 ]]; then
        # hack to fix spacing with icons
        if [ $push_status == $push_icon ] || [ $push_status == $laptop ]; then
            local dca=" +${commits_ahead}"
        else 
            local dca="+${commits_ahead}"
        fi
    else
        local dca=" --"
    fi

    # type of upstream icon
    if [[ $will_rebase == true ]]; then
        local type_of_upstream=$rebase_icon
    else
        local type_of_upstream=$merge_icon
    fi    

    # build branch/upstream
    local branch="$git_branch"
    if [[ $has_upstream == true ]]; then
        if [[ $will_rebase == true ]]; then
            branch+=" $rebase_icon"
        else
            branch+=" $merge_icon"
        fi

        # get the upstream
        local upstream_branch=$(git branch -vv | grep -E '^\* ' | cut -d "[" -f2 | cut -d "]" -f1 | cut -d ":" -f1)
        branch+=" $upstream_branch"
    fi

    # tags
    local tag=""
    if [[ $is_on_a_tag == true ]]; then
        tag="${tag_icon} v${tag_at_current_commit}"
    fi

    # prep display
    local start="$path_arrow$arrow$repo_colors ${git_logo} "

    # return the display
    echo -e "${start}${status}  $status_arrow_colors$arrow ${remote_colors}${dcb} ${push_status} ${dca} (${branch}) ${tag} $end_colors$end_icon"
  else
    path_arrow="\001\033[90;49m\002"
    echo -e "$path_arrow$arrow"
  fi
}