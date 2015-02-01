#!/bin/sh

mongodump --host $MONGOHQ_HOST:$MONGOHQ_PORT --db $MONGOHQ_DB -u $MONGOHQ_USER -p $MONGOHQ_PASSWORD -o ./dump/heroku/
#tar czvf dump/db_dump_$(date '+%Y%m%d-%H-%M').tgz dump/heroku/

