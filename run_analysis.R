library(httr)
library("httpuv")
library("sqldf")
library(XML)
library(reshape)
library(reshape2)

##setwd('C:/Users/simon.monk/Documents/Data Science Course/Getting & Cleaning Data/getdata-projectfiles-UCI HAR Dataset/UCI HAR Dataset/')

activityLabels <- read.table("activity_labels.txt")
activityLabels[,2] <- as.character(activityLabels[,2])
features <- read.table("features.txt")
features[,2] <- as.character(features[,2])

##Get the rows of the features we want
featuresWanted <- grep(".*mean.*|.*std.*", features[,2])
##Get the feature names associated with the rows we just saved
feature.Labels <- features[featuresWanted, 2]
feature.Labels

#Clean up the names a bit
feature.Labels <- gsub('[-()]', '', feature.Labels)
feature.Labels

#Load the datasets
  #Note that each column is a feature in the X_train.txt and X_test.text data sets
    ###Train set
training <- read.table("train/X_train.txt")[featuresWanted]
trainingActivities <- read.table("train/Y_train.txt")
trainingSubjects <- read.table("train/subject_train.txt")
trainingData <- cbind(trainingSubjects, trainingActivities, training)

    ###Test Set
testing <- read.table("test/X_test.txt")[featuresWanted]
testingActivities <- read.table("test/Y_test.txt")
testingSubjects <- read.table("test/subject_test.txt")
testingData <- cbind(testingSubjects, testingActivities, testing)

combined <- rbind(trainingData, testingData)
colnames(combined) <- c("Subject", "Activity", feature.Labels)
colnames(combined)

## Replace activitely identifiers with factor labels
  ## Levels argument indicates the values that the column could be
    ## Labels indicates the corresponding labels to replace the integer identifiers with
combined$Activity <- factor(combined$Activity, levels=activityLabels[,1], labels = activityLabels[,2])

##This "melts" data into a unique row for each Variable/Activity/Subject combination
  ## Essentially it is a pivot
combined.Melted <- melt(combined, id = c("Subject", "Activity"))
## This calculates the mean of each variable for each Subject & Acivity and returns
  ## a data.frame with variables as columns and Subject/ACtivity combinations as rows
combined.mean <- dcast(combined.Melted, Subject + Activity ~ variable, mean)

write.table(combined.mean, "tidy.txt", row.names = FALSE, quote = FALSE)
