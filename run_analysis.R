library(dplyr)
library(tidyr)
download.file("https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip", destfile="smartphone.zip")
unzip("smartphone.zip")
##read all the relevant data, including the features
trainx<-read.table("./UCI HAR Dataset/train/X_train.txt")
trainact<-read.csv("./UCI HAR Dataset/train/y_train.txt", header=FALSE, sep=" ")
trainsubj<-read.csv("./UCI HAR Dataset/train/subject_train.txt", header=FALSE, sep=" ")

testx<-read.table("./UCI HAR Dataset/test/X_test.txt")
testact<-read.csv("./UCI HAR Dataset/test/y_test.txt", header=FALSE, sep=" ")
testsubj<-read.csv("./UCI HAR Dataset/test/subject_test.txt", header=FALSE, sep=" ")
features<-read.csv("./UCI HAR Dataset/features.txt", header=FALSE, sep=" ")

##the names in the second column of features
featurestext<-as.character(features[,2])

##merging all the data, giving names to the columns
alldata<-rbind(data.frame(trainsubj, trainact, trainx), data.frame(testsubj, testact, testx))
names(alldata)<-c(c("subject", "activity"), featurestext)

##lower case for all names to make it search friendly
names(alldata)<-tolower(names(alldata))

##which columns have mean or std in the title? Then subset the data.
meanstd<-grep("mean|std", names(alldata))
data.meanstd <- alldata[,c(1,2, meanstd)]

##just as before with the features
labels<-read.table("./UCI HAR Dataset/activity_labels.txt", header=FALSE)
labelstext<-as.character(labels[,2])

##now change the labels (i.e. update table with activity name)
data.meanstd$activity <- labelstext[data.meanstd$activity]

##replace variable names
names(data.meanstd)<-gsub("gyro", " Gyroscope ", names(data.meanstd))
names(data.meanstd)<-gsub("acc", " Acceleration ", names(data.meanstd))
names(data.meanstd)<-gsub("-mean", " Mean ", names(data.meanstd))
names(data.meanstd)<-gsub("-std", " St. Dev. ", names(data.meanstd))
names(data.meanstd)<-gsub("mag", " Magnitude ", names(data.meanstd))
names(data.meanstd)<-gsub("^f", "Frequency ", names(data.meanstd))
names(data.meanstd)<-gsub("^t", "Time ", names(data.meanstd))
names(data.meanstd)<-gsub("bodybody", "body", names(data.meanstd))
names(data.meanstd)<-gsub("()", "", names(data.meanstd))
names(data.meanstd)<-gsub("mean", " mean", names(data.meanstd))
names(data.meanstd)<-gsub("freq", "Frequency", names(data.meanstd))

## Independent data set with averages across each activity
newdataset <- data.meanstd

##To get a mean for each subject/activity combo, I'll unite the subject 
##and the activity columns, then call summarize_all with .funs set to mean.
uniteddata<-unite(newdataset, "Subject_Activity", c("subject", "activity"))
groupeddata<-group_by(uniteddata, Subject_Activity)
meansdata<-summarize_all(groupeddata, .funs=mean)
write.table(meansdata, "tidydata.txt", row.name=FALSE)
