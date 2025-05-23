#!/bin/bash

APP_NAME="rabbitmq"

source ./common.sh $APP_NAME

cp $SCRIPT_DIR/repos/rabbitmq.repo /etc/yum.repos.d/rabbitmq.repo 
VALIDATE $? "Copying rabbitmq repo to /etc/yum.repos.d"

dnf install rabbitmq-server -y &>>$LOG_FILE
VALIDATE $? "Installing rabbitmq server"

systemctl enable rabbitmq-server &>>$LOG_FILE
systemctl start rabbitmq-server &>>$LOG_FILE
VALIDATE $? "Enabling & starting rabbitmq server"

rabbitmqctl add_user roboshop roboshop123 &>>$LOG_FILE
rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*" &>>$LOG_FILE
VALIDATE $? "Adding rabbitmq user and setting permissions"

PRINT_TIME