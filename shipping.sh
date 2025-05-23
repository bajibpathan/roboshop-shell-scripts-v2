#!/bin/bash


APP_NAME="shipping"

source ./common.sh $APP_NAME

IS_USER_ROOT

echo "Enter root password"
read -s MYSQL_ROOT_PASSWORD

SYSTEM_USER_SETUP
APP_SETUP

dnf install maven -y &>>$LOG_FILE
VALIDATE $? "Installing Maven"

mvn clean package &>>$LOG_FILE
VALIDATE $? "Packaging the shipping code"

mv target/shipping-1.0.jar shipping.jar 
VALIDATE $? "Renaming shipping jar"

SYSTEMD_SETUP

dnf install mysql -y &>>$LOG_FILE
VALIDATE $? "Installing MySql" 

mysql -h mysql.robodevops.store -uroot -p$MYSQL_ROOT_PASSWORD < /app/db/schema.sql &>>$LOG_FILE
mysql -h mysql.robodevops.store -uroot -p$MYSQL_ROOT_PASSWORD < /app/db/app-user.sql &>>$LOG_FILE
mysql -h mysql.robodevops.store -uroot -p$MYSQL_ROOT_PASSWORD < /app/db/master-data.sql &>>$LOG_FILE
VALIDATE $? "Loading data to MySql" 

systemctl restart shipping &>>$LOG_FILE
VALIDATE $? "Restarting shipping service"

PRINT_TIME