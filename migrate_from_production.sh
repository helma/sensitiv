#!/bin/bash
#===============================================================================
#
#          FILE:  migrate_from_production.sh
# 
#         USAGE:  ./migrate_from_production.sh 
# 
#   DESCRIPTION: migrate from current pruduction database 
# 
#       OPTIONS:  ---
#  REQUIREMENTS:  ---
#          BUGS:  ---
#         NOTES:  ---
#        AUTHOR:   (), 
#       COMPANY:  
#       VERSION:  1.0
#       CREATED:  07/04/2007 01:11:14 PM CEST
#      REVISION:  ---
#===============================================================================

rsync -v sensitiv:/var/www/sensitiv/shared/db/production.sqlite3 db/production.sqlite3
cp db/production.sqlite3 db/development.sqlite3
rake db:schema:dump
rake db:migrate --trace
