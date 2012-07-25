#!/bin/sh

wget https://dl.dropbox.com/u/7755294/Question_properties.xlsx
mv Question_properties.xlsx ./spreadsheet/

git add spreadsheet/.
git commit -m "spreadsheet updated"
git push origin master
git push heroku master
   
heroku run rake ADMIN_PASSWORD=secret db:populate

