#!/bin/bash

APP_NAME="catalogue"

source ./common.sh $APP_NAME

IS_USER_ROOT
SYSTEM_USER_SETUP
APP_SETUP
NODEJS_SETUP
SYSTEMD_SETUP

cp $SCRIPT_DIR/repos/mongo.repo /etc/yum.repos.d/mongo.repo
dnf install mongodb-mongosh -y &>>$LOG_FILE
VALIDATE $? "Installing MongoDB Client"

STATUS=$(mongosh --host mongodb.robodevops.store --eval 'db.getMongo().getDBNames().indexOf("catalogue")')
if [ $STATUS -lt 0 ]
then
    mongosh --host mongodb.robodevops.store </app/db/master-data.js &>>$LOG_FILE
    VALIDATE $? "Copying the data to MongoDB Database"
else
    echo -e "Data is already loaded ... $YELLOW SKIPPING $NOCOLOR"
fi

PRINT_TIME
