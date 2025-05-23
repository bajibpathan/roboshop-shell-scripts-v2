#!/bin/bash

APP_NAME="dispatch"

source ./common.sh $APP_NAME

dnf install golang -y &>>$LOG_FILE
VALIDATE $? "Installing GoLang"

SYSTEM_USER_SETUP
APP_SETUP

go mod init dispatch &>>$LOG_FILE
VALIDATE $? "initializing go module"

go get &>>$LOG_FILE
VALIDATE $? "Downloading dependencies"

go build &>>$LOG_FILE
VALIDATE $? "Installing dependencies"

SYSTEMD_SETUP
PRINT_TIME