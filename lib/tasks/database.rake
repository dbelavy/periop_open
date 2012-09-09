namespace :database do

  desc "Copy production database to local"
  task :sync => :environment do
    #mongodump --host staff.mongohq.com:10091 --db $MONGOHQ_DB -u $MONGOHQ_USER -p $MONGOHQ_PASSWORD -o ./dump/heroku/
    #
    #    system 'mongodump -h flame.mongohq.com:27053 -d YOUR_HEROKU_APP_NAME -u heroku -p HEROKU_PASSWORD -o db/backups/'
    #system 'mongorestore -h localhost --drop -d DEV_DATABASE_NAME db/backups/YOUR_HEROKU_APP_NAME/'
  end

end
