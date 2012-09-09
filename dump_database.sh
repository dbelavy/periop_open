#!/bin/sh

mongodump --host staff.mongohq.com:10091 --db $MONGOHQ_DB -u $MONGOHQ_USER -p $MONGOHQ_PASSWORD -o ./dump/heroku/
tar czvf dump/db_dump_$(date '+%Y%m%d-%H-%M').tgz dump/heroku/

