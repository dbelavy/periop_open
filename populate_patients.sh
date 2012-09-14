#!/bin/sh

if [ $# != 1 ] ; then
  echo 'usage populate_patients.sh testserver.com'
  exit
fi
TEST_SERVER=http://$1 rspec spec/integration/patients_spec.rb -e "patient_create"

