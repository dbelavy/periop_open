#!/bin/bash
PS3='Please enter your choice: '
options=("Change to Demo user" "Change to Production user" "Update questions Demo" "Update questions Production" "Ad hoc backup Demo" "Ad hoc backup Production" "Keep Demo alive" "Push to Demo" "Quit")
select opt in "${options[@]}"
do
    case $opt in
        "Change to Demo user")
            echo "you chose choice 1"
            heroku accounts:set Demo
            ;;
        "Change to Production user")
            echo "you chose choice 2"
            heroku accounts:set Production
            ;;   
        "Update questions Demo")
            echo "you chose choice 3"
            heroku run rake db:update_questions --app pre-op-demo
            ;;
        "Update questions Production")
            echo "you chose choice 4"
            heroku run rake db:update_questions --app pre-op
            ;;
        "Ad hoc backup Demo")
            echo "you chose choice 5"
            heroku run rake mongo:backup --app pre-op-demo
            ;;
        "Ad hoc backup Production")
            echo "you chose choice 6"
            heroku run rake mongo:backup --app pre-op
            ;;
        "Keep Demo alive")
            while :
            	do		
				curl -kv https://pre-op-demo.herokuapp.com
				sleep 60	
			done
			;;
		"Push to Demo")
			echo "You chose to Push to Demo"
			echo "Set account to Demo"
			heroku accounts:set Demo
			echo "Backup demo"
			heroku run rake mongo:backup --app pre-op-demo
			echo "Push"
			git push -v --tags Demo master:master
			echo "Run migration script"
			heroku run rake db:migrate --app pre-op-demo
			echo "Update questions"
			heroku run rake db:update_questions --app pre-op-demo
			;;
        "Quit")
            break
            ;;
        *) echo invalid option;;
    esac
done