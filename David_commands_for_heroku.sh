#!/bin/bash
PS3='Please enter your choice: '
options=("Change to Demo user" "Change to Production user"  "Ad hoc backup Demo" "Ad hoc backup Production" "Keep Demo alive" "Push to Demo" "Push to Production" "Push to Staging with db migrate" "Push to Staging WITHOUT DB migration" "Push to Github" "Push to All including Github" "Use Inspectlet" "Turn Inspectlet off" "Quit")
select opt in "${options[@]}"
do
    case $opt in
        "Change to Demo user")
            echo "you chose change to Demo user"
            heroku accounts:set Demo
            ;;
        "Change to Production user")
            echo "you chose change to Production user"
            heroku accounts:set Production
            ;;   

        "Ad hoc backup Demo")
            echo "you chose Ad hoc backup demo"
            heroku run rake mongo:backup --app pre-op-demo
            ;;
        "Ad hoc backup Production")
            echo "you chose choice Ad hoc backup Production"
            heroku run rake mongo:backup --app pre-op
            ;;
        "Keep Demo alive")
        	echo "you chose Keep demo alive"
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
			git push -v --tags demo master:master
			echo "Update questions"
			heroku run rake db:update_questions --app pre-op-demo
			echo "Run migration script"
			heroku run rake db:migrate --app pre-op-demo
			echo "Remember to update your backup *************"
			;;
		"Push to Production")
			echo "You chose to Push to Production"
			echo "Set account to Production"
			heroku accounts:set Production
			echo "Backup Production"
			heroku run rake mongo:backup --app pre-op
			echo "Push"
			git push -v --tags production master:master
			echo "Update questions"
			heroku run rake db:update_questions --app pre-op
			echo "Run migration script"
			heroku run rake db:migrate --app pre-op
			echo "*******Check all the messages to ensure none of it failed*******"
			;;
		"Push to Staging with db migrate")
			echo "You chose to Push to Staging"
			echo "Set account to Demo"
			heroku accounts:set Demo
			echo "Push"
			git push -v --tags staging master:master
			echo "Update questions"
			heroku run rake db:update_questions --app periop
			echo "Run migration script"
			heroku run rake db:migrate --app periop
			echo "*******Check all the messages to ensure none of it failed*******"
			;;	
 	  	"Push to Staging WITHOUT DB migration")
            		echo "You chose to Push to Staging"
            		echo "Set account to Demo"
            		heroku accounts:set Demo
            		echo "Push"
            		git push -v --tags staging master:master
            		echo "Update questions"
        	    	heroku run rake db:update_questions --app periop
           		 echo "*******Check all the messages to ensure none of it failed*******"
            		;;

		 "Push to Github")
			echo "You chose push to Github"
			echo "Pushing to github"
			git push origin
			;;



		 "Push to All including Github")

			echo "You chose to Push to All environments."

			echo "Pushing to github"
				git push origin

			echo "Pushing to Staging"
			echo "Set account to Demo"
				heroku accounts:set Demo
			echo "Push"
				git push -v --tags staging master:master
			echo "Update questions"
				heroku run rake db:update_questions --app periop
			echo "Run migration script"
				heroku run rake db:migrate --app periop
			
			
			echo "Pushing to Demo"
			echo "Set account to Demo"
			heroku accounts:set Demo
			echo "Backup demo"
			heroku run rake mongo:backup --app pre-op-demo
			echo "Push"
			git push -v --tags demo master:master
			echo "Update questions"
			heroku run rake db:update_questions --app pre-op-demo
			echo "Run migration script"
			heroku run rake db:migrate --app pre-op-demo
			
			echo "You chose to Push to Production"
			echo "Set account to Production"
			heroku accounts:set Production
			echo "Backup Production"
			heroku run rake mongo:backup --app pre-op
			echo "Push"
			git push -v --tags production master:master
			echo "Update questions"
			heroku run rake db:update_questions --app pre-op
			echo "Run migration script"
			heroku run rake db:migrate --app pre-op
			echo "*******Check all the messages to ensure none of it failed*******"
			echo "*******remember to update the backup for pre-op-demo.herokuapp.com*******"

			;;
			
		"Use Inspectlet")
			heroku accounts:set Production
			heroku config:set USE_INSPECTLET=true --app pre-op
			;;
			
		"Turn Inspectlet off")
			heroku accounts:set Production
			heroku config:set USE_INSPECTLET=false --app pre-op
			;;



        "Quit")
            break
            ;;

        *) 
			echo invalid option;;

    esac
done
