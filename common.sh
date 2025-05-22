#!/bin/bash

START_TIME=$(date +%s)
USERID=$(id -u)
RED="\e[31m"
GREEN="\e[32m"
YELLOW="\e[33m"
NOCOLOR="\e[0m"
LOGS_FOLDER="/var/log/roboshop-logs"
# SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
SCRIPT_NAME=$1
LOG_FILE="$LOGS_FOLDER/$SCRIPT_NAME.log"

# Create log folder
mkdir -p $LOGS_FOLDER
echo "Script started executing: $(date)" | tee -a $LOG_FILE

# Check if the user has proper privileges to run the script
IS_USER_ROOT() {
    if [ $USERID -ne 0 ]
    then
        echo -e "$RED ERROR:: Please run this script with root access $NOCOLOR" | tee -a $LOG_FILE
        exit 1
    else
        echo "You are running with root access"  | tee -a $LOG_FILE
    fi
}

########################
# Funtion: Validation
# Purpose: Validate if the given package is installed or not
# Argument: Exit status & Package name
########################
VALIDATE(){
    if [ $? -eq 0 ]
    then
        echo -e "$2 is ... $GREEN SUCCESS $NOCOLOR"  | tee -a $LOG_FILE
    else
        echo -e "$2 is ...$RED FAILURE $NOCOLOR"  | tee -a $LOG_FILE
        exit 1
    fi
}
NODEJS_SETUP(){
    dnf module disable nodejs -y &>>$LOG_FILE
    VALIDATE $? "Disabling NodeJS default module"

    dnf module enable nodejs:20 -y &>>$LOG_FILE
    VALIDATE $? "Enabling NodeJS default module"

    dnf install nodejs -y &>>$LOG_FILE
    VALIDATE $? "Installing NodeJS"

    npm install &>>$LOG_FILE
    VALIDATE $? "Installing dependencies"

}

SYSTEM_USER_SETUP(){
    id roboshop &>>$LOG_FILE
    if [ $? -ne 0 ]
    then
        useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$LOG_FILE
        VALIDATE $? "Creating a roboshop system user"
    else
        echo -e "System user roboshop already created ... $YELLOW SKIPPING $NOCOLOR" 
    fi
}

APP_SETUP(){
    mkdir -p /app
    VALIDATE $? "Creating /app directory"

    curl -o /tmp/$APP_NAME.zip https://roboshop-artifacts.s3.amazonaws.com/$APP_NAME-v3.zip &>>$LOG_FILE
    VALIDATE $? "Downloading $APP_NAME code to temp directory"

    rm -rf /app/*
    cd /app 
    unzip /tmp/$APP_NAME.zip &>>$LOG_FILE
    VALIDATE $? "Extracting the $APP_NAME code to /app directory"
}

SYSTEMD_SETUP(){
    cp $SCRIPT_DIR/services/$APP_NAME.service /etc/systemd/system/$APP_NAME.service
    VALIDATE $? "Copying $APP_NAME serivce to systemd directory"

    systemctl daemon-reload &>>$LOG_FILE
    systemctl enable $APP_NAME &>>$LOG_FILE
    systemctl start $APP_NAME &>>$LOG_FILE
    VALIDATE $? "Enabling & Starting $APP_NAME service"

}

# To print the script execution time and status
PRINT_TIME(){
    END_TIME=$(date +%s)
    TOTAL_TIME=$(( $END_TIME - $START_TIME))
    echo -e "Script execution completed successfully, $YELLOW time taken: $TOTAL_TIME seconds $NOCOLOR" | tee -a $LOG_FILE
}