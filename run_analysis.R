#################################################################################################################
#####                       COURSERA COURSE:  GETTING AND CLEANSING DATA                                    #####
#####                                       COURSE PROJECT                                                  #####
#####                                                                                                       #####
#####   OBJECTIVES: You should create one R script called run_analysis.R that does the following.           #####                                                                              #####
#####         1.  Merges the training and the test sets to create one data set.                             #####
#####         2.  Extracts only the measurements on the mean and standard deviation for each measurement.   #####
#####         3.  Uses descriptive activity names to name the activities in the data set                    #####
#####         4.  Appropriately labels the data set with descriptive variable names.                        #####
#####         5.  From the data set in step 4, creates a second, independent tidy data set with the average #####
#####             of each variable for each activity and each subject.                                      #####
#################################################################################################################

## STEP1:  Download the Data

ZIP_URL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(ZIP_URL, "Coursera Getting and Cleansing Data Course Project Data.zip")
unzip("Coursera Getting and Cleansing Data Course Project Data.zip")

## STEP2:  Read the data into R

#Train datasets
subject_train <- read.table("UCI HAR Dataset/train/subject_train.txt", colClasses = "character", na.string = "Not Available", stringsAsFactors = FALSE)
x_train <- read.table("UCI HAR Dataset/train/X_train.txt", colClasses = "numeric", na.string = "Not Available", stringsAsFactors = FALSE)
y_train <- read.table("UCI HAR Dataset/train/y_train.txt", colClasses = "character", na.string = "Not Available", stringsAsFactors = FALSE)

Train_Master <- cbind(subject_train,y_train,x_train)

#Test Datsets


subject_test <- read.table("UCI HAR Dataset/test/subject_test.txt", colClasses = "character", na.string = "Not Available", stringsAsFactors = FALSE)
x_test <- read.table("UCI HAR Dataset/test/x_test.txt", colClasses = "numeric", na.string = "Not Available", stringsAsFactors = FALSE)
y_test <- read.table("UCI HAR Dataset/test/y_test.txt", colClasses = "character", na.string = "Not Available", stringsAsFactors = FALSE)


Test_Master <- cbind(subject_test,y_test,x_test)

Smartphone_Study <- rbind(Train_Master,Test_Master)

## STEP 3:  NAME THE COLUMNS

features <- read.table("UCI HAR Dataset/features.txt", colClasses = "character", na.string = "Not Available", stringsAsFactors = FALSE)

feature_names <- as.vector(features[,2])
subject_act_names <- c("Subject","Activity")
names_vector <- c(subject_act_names,feature_names) 

names(Smartphone_Study) <- names_vector

#get list of only mean/std fields here for later use
library(dplyr)
mean_or_std <- filter(features, grepl('mean()|std()', V2))
mean_or_std2 <- filter(mean_or_std, !grepl('meanFreq()',V2))
mean_or_std3 <- as.vector(mean_or_std2[,2])
feature_names_mean_std  <- c(subject_act_names,mean_or_std3)

## STEP 4:  KEEP ONLY MEAN AND STANDARD DEVIATION OF EACH MEASUREMENT

Smartphone_Study_Reduc = Smartphone_Study[feature_names_mean_std]

## STEP 5:  NAME ACTIVITIES
## Looping through the file, apply activity names to the codes.

Smartphone_Study_Reduc$Activity <- as.character(Smartphone_Study_Reduc$Activity)
Smartphone_Study_Reduc$Activity[Smartphone_Study_Reduc$Activity == "1"] <- "Walking"
Smartphone_Study_Reduc$Activity[Smartphone_Study_Reduc$Activity == "2"] <- "Walking Upstairs"
Smartphone_Study_Reduc$Activity[Smartphone_Study_Reduc$Activity == "3"] <- "Walking Downstairs"
Smartphone_Study_Reduc$Activity[Smartphone_Study_Reduc$Activity == "4"] <- "Sitting"
Smartphone_Study_Reduc$Activity[Smartphone_Study_Reduc$Activity == "5"] <- "Standing"
Smartphone_Study_Reduc$Activity[Smartphone_Study_Reduc$Activity == "6"] <- "Laying"

## STEP 6:  DATASET WITH THE AVERAGE OF EACH MEASURE BY ACTIVITY & SUBJECT

library(reshape2)

## Tidy Data - Long Format by Melting the Dataset, then average measures

Smartphone_Study_Reduc$Subject <- as.factor(Smartphone_Study_Reduc$Subject)
Smartphone_Study_Reduc$Activity <- as.factor(Smartphone_Study_Reduc$Activity)

Smartphone_Study_Melt <- melt(Smartphone_Study_Reduc,id = subject_act_names, measure.vars = mean_or_std3)

Smartphone_Study_Averages <- dcast(Smartphone_Study_Melt, Subject + Activity ~ variable, fun.aggregate = mean, na.rm=TRUE)

Smartphone_Study_Averages$Subject <- as.numeric(Smartphone_Study_Averages$Subject)

Smartphone_Study_Averages <- arrange(Smartphone_Study_Averages,Subject)

## STEP 7:  OUTPUT FINAL DATASET

write.table(Smartphone_Study_Averages,"Smartphone Study Averages.txt",row.name=FALSE)
