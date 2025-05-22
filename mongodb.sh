#!/bin/bash

APP_NAME="mongodb"

source ./common.sh $APP_NAME

IS_USER_ROOT

cp repos/mongo.repo /etc/yum.repos.d/mongo.repo
VALIDATE $? "Copying MongoDB repo to yum.repos"

dnf install mongodb-org -y &>>$LOG_FILE 
VALIDATE $? "Installing mongodb server"

systemctl enable mongod &>>$LOG_FILE
VALIDATE $? "Enabling MongoDB"

systemctl start mongod &>>$LOG_FILE
VALIDATE $? "Starting MongoDB"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf
VALIDATE $? "Editing MongoDB conf file for remote connections"

systemctl restart mongod &>>$LOG_FILE
VALIDATE $? "Restarting MongoDB"

PRINT_TIME