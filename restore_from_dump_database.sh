#!/bin/sh

if [ $1 == 'live' ] ;
then

# live
  mongorestore -h localhost --drop -d periop_development dump/heroku/app8014812/

else
# staging
  mongorestore -h localhost --drop -d periop_development dump/heroku/app4695128/

fi
