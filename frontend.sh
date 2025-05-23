#!/bin/bash

APP_NAME="frontend"

source ./common.sh $APP_NAME

IS_USER_ROOT

dnf module disable nginx -y &>>$LOG_FILE
VALIDATE $? "Disabling the nginx modules"

dnf module enable nginx:1.24 -y &>>$LOG_FILE
VALIDATE $? "Enabling the nginx modules"

dnf install nginx -y &>>$LOG_FILE
VALIDATE $? "Installing nginx"

systemctl enable nginx &>>$LOG_FILE
systemctl start nginx &>>$LOG_FILE
VALIDATE $? "Starting nginx"

rm -rf /usr/share/nginx/html/*
VALIDTE $? "Removing default content"

curl -o /tmp/frontend.zip https://roboshop-artifacts.s3.amazonaws.com/frontend-v3.zip &>>$LOG_FILE
VALIDATE $? "Downloading the content"

cd /usr/share/nginx/html 
unzip /tmp/frontend.zip &>>$LOG_FILE
VALIDATE $? "Unzipping the frontend content"

cp $SCRIPT_DIR/conf/nginx.conf /etc/nginx/nginx.conf
VALIDATE $? "Copying nginx configuration"

systemctl restart nginx &>>$LOG_FILE
VALIDATE $? "Restarting the nginx service"

PRINT_TIME