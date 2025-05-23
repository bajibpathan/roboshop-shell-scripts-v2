#!/bin/bash


APP_NAME="payment"

source ./common.sh $APP_NAME

IS_USER_ROOT

SYSTEM_USER_SETUP
APP_SETUP

dnf install python3 gcc python3-devel -y &>>$LOG_FILE
VALIDATE $? "Installing Python3"

pip3 install -r requirements.txt &>>$LOG_FILE
VALIDATE $? "Installing requirements"

SYSTEMD_SETUP

PRINT_TIME