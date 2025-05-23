#!/bin/bash

APP_NAME="redis"

source ./common.sh $APP_NAME

IS_USER_ROOT

dnf module disable redis -y &>>$LOG_FILE
VALIDATE $? "Disabling default redis module"

dnf module enable redis:7 -y &>>$LOG_FILE
VALIDATE $? "Enabling redis 7 module"

dnf install redis -y &>>$LOG_FILE
VALIDATE $? "Installing Redis"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/redis/redis.conf &>>$LOG_FILE
sed -i 's/protected-mode yes/protected-mode no/' /etc/redis/redis.conf &>>$LOG_FILE
VALIDATE $? "Edited redis.conf to accept remote connections"

systemctl enable redis &>>$LOG_FILE
systemctl start redis &>>$LOG_FILE
VALIDATE $? "Enabling and starting redis"

PRINT_TIME