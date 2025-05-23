#!/bin/bash


APP_NAME="mysql"

source ./common.sh $APP_NAME

echo "Enter root password"
read -s MYSQL_ROOT_PASSWORD

dnf install mysql-server -y &>>$LOG_FILE
VALIDATE $? "Installing  MySql Server"

systemctl enable mysqld &>>$LOG_FILE
systemctl start mysqld  &>>$LOG_FILE
VALIDATE $? "Enabling and Starting MySql Server"

mysql_secure_installation --set-root-pass $MYSQL_ROOT_PASSWORD
VALIDATE $? "Setting MySQL root password"

PRINT_TIME