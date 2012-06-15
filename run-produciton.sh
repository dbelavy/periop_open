#!/bin/sh
RAILS_ENV=production MONGOHQ_URL=mongodb://localhost/periop_production bundle exec rails s
