#!/bin/sh

# staging
# mongorestore -h localhost --drop -d periop_development dump/heroku/app4695128/

# live
mongorestore -h localhost --drop -d periop_development dump/heroku/app8014812/

