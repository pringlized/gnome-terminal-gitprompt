# gnome-terminal-gitprompt
Customized gnome-terminal prompt with git insight

### Sections
- services: background reflects loads.
- user@host
- path
- git info

##### Base prompt with low load
![alt text](images/low_load.png "Base prompt, low load")

##### Base prompt with medium load
![alt text](images/medium_load.png "Base prompt, medium load")

##### Base prompt with high load
![alt text](images/high_load.png "Base prompt, high load")

###### Prompt including git. Inspired by and most code from [oh-my git](https://github.com/arialdomartini/oh-my-git/blob/master/README.md)
![alt text](images/with_git.png "Base prompt")

##### As root user.  Simple: no services, load indication or git info
![alt text](images/root_user.png "Root user")

### Available services:
- docker
- postgresql
- mysqld
- mariadb

### Todo:
- make services more dynamic so they can easily added/removed
