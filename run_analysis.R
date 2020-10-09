## R script for getting and cleaning data project
## Author: Pradeep K. Pant
## Load CRAN modules 
library(downloader)
library(plyr);
library(knitr)
## Stpe 1: Download the dataset and unzip folder

## Check if directory already exists?
if(!file.exists("./projectData")){
  dir.create("./projectData")
  }
Url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
## Check if zip has already been downloaded in projectData directory?
if(!file.exists("./projectData/project_Dataset.zip")){
  download.file(Url,destfile="./projectData/project_Dataset.zip",mode = "wb")
  }
## Check if zip has already been unzipped?
if(!file.exists("./projectData/UCI HAR Dataset")){
  unzip(zipfile="./projectData/project_Dataset.zip",exdir="./projectData")
}
## List all the files of UCI HAR Dataset folder
path <- file.path("./projectData" , "UCI HAR Dataset")
files<-list.files(path, recursive=TRUE)
## The files that will be used to load data are listed as follows:
# test/subject_test.txt
# test/X_test.txt
# test/y_test.txt
# train/subject_train.txt
# train/X_train.txt
# train/y_train.txt

## Stpe 2: Load activity, subject and feature info.
## Read data from the files into the variables

## 1. Read the Activity files
ActivityTest  <- read.table(file.path(path, "test" , "Y_test.txt" ),header = FALSE)
ActivityTrain <- read.table(file.path(path, "train", "Y_train.txt"),header = FALSE)

## 2. Read the Subject files
SubjectTrain <- read.table(file.path(path, "train", "subject_train.txt"),header = FALSE)
SubjectTest  <- read.table(file.path(path, "test" , "subject_test.txt"),header = FALSE)

## 3. Read Fearures files
FeaturesTest  <- read.table(file.path(path, "test" , "X_test.txt" ),header = FALSE)
FeaturesTrain <- read.table(file.path(path, "train", "X_train.txt"),header = FALSE)

## Test: Check properties

##str(ActivityTest)
##str(ActivityTrain)
##str(SubjectTrain)
##str(SubjectTest)
##str(FeaturesTest)
##str(FeaturesTrain)

## Stpe 3: Merges the training and the test sets to create one data set.

## 1.Concatenate the data tables by rows
dataSubject <- rbind(SubjectTrain, SubjectTest)
dataActivity<- rbind(ActivityTrain, ActivityTest)
dataFeatures<- rbind(FeaturesTrain, FeaturesTest)

## 2. Set names to variables
names(dataSubject)<-c("subject")
names(dataActivity)<- c("activity")
dataFeaturesNames <- read.table(file.path(path, "features.txt"),head=FALSE)
names(dataFeatures)<- dataFeaturesNames$V2

## 3. Merge columns to get the data frame Data for all data
dataCombine <- cbind(dataSubject, dataActivity)
Data <- cbind(dataFeatures, dataCombine)

## Step 4: Extracts only the measurements on the mean and standard deviation for each measurement.
## 1. Subset Name of Features by measurements on the mean and standard deviation
## i.e taken Names of Features with "mean()" or "std()"
## Extract using grep
subdataFeaturesNames<-dataFeaturesNames$V2[grep("mean\\(\\)|std\\(\\)", dataFeaturesNames$V2)]
## 2. Subset the data frame Data by seleted names of Features
selectedNames<-c(as.character(subdataFeaturesNames), "subject", "activity" )
Data<-subset(Data,select=selectedNames)
## 3. Test : Check the structures of the data frame Data
##str(Data)

## Step 5: Uses descriptive activity names to name the activities in the data set
## 1. Read descriptive activity names from "activity_labels.txt"
activityLabels <- read.table(file.path(path, "activity_labels.txt"),header = FALSE)
## 2. Factorize Variale activity in the data frame Data using descriptive activity names
Data$activity<-factor(Data$activity,labels=activityLabels[,2])
## Test Print
head(Data$activity,30)

## Step 6: Appropriately labels the data set with descriptive variable names
names(Data)<-gsub("^t", "time", names(Data))
names(Data)<-gsub("^f", "frequency", names(Data))
names(Data)<-gsub("Acc", "Accelerometer", names(Data))
names(Data)<-gsub("Gyro", "Gyroscope", names(Data))
names(Data)<-gsub("Mag", "Magnitude", names(Data))
names(Data)<-gsub("BodyBody", "Body", names(Data))
## Test Print
names(Data)

## Step 7: Creates a independent tidy data set

newData<-aggregate(. ~subject + activity, Data, mean)
newData<-newData[order(newData$subject,newData$activity),]
write.table(newData, file = "tidydata.txt",row.name=FALSE,quote = FALSE, sep = '\t')
