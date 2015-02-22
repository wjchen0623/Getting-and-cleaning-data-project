# Getting and Cleaning Data: Course Project
## Introduction
The task at hand was create one R script called run_analysis.R that does the following.  
1. Merges the training and the test sets to create one data set.  
2. Extracts only the measurements on the mean and standard deviation for each measurement.  
3. Uses descriptive activity names to name the activities in the data set  
4. Appropriately labels the data set with descriptive variable names.  
5. From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject. 

The dataset can be found: https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip  
The dataset comes with a "Readme.txt" which explains the background to the data

## Variables
The following variables were used:  
* `subject` - the serial number of the test subject  
* `activity` - the activity undertaken  
A summary of all the Variables used can be found in features_info.txt which is in the zip file.

## Transformations for Points 1 - 4
*Important:* *Set the directory with the dataset used for the exercise as the working directory for the session.*  
The first four tasks were undertaken together.

### Merging the training and test datasets
The feature files were read and combined into dataframe:`features` using `rbind`. Following which, the intermediate objects were removed to save memory space.
```
train.features = read.table("train/X_train.txt")
test.features = read.table("test/X_test.txt")
features = rbind(train.features, test.features)
remove(train.features, test.features)
```
The labels were read from "features.txt". The data is in column 2, but has to be transposed (`t`) before being subsequently added to the `features` dataframe.
```
### Reading feature labels
label.features = read.table("features.txt")
colnames(features) = t(label.features[2])
remove(label.features)
```

### Reading the subject & activity
The subject was read from the training and test sets, and combined into `subject` dataframe. The column was also labelled as "subject".
```
train.sub = read.table("train/subject_train.txt")
test.sub = read.table("test/subject_test.txt")
subject = rbind(train.sub, test.sub)
remove(train.sub, test.sub)
colnames(subject) = "subject"
```

The activity was read into the 'activities' dataframe, as factors to facilitate changing it to descriptive activity names.
```
### Reading activities
train.act = read.table("train/y_train.txt", colClasses = "factor")
test.act = read.table("test/y_test.txt", colClasses = "factor")
activities = rbind(train.act, test.act)
remove(train.act, test.act)
colnames(activities) = "activity"
```
The activity labels were read, and used to relevel the `activity` dataframe
```
### Reading activity labels
act.label = read.table("activity_labels.txt", colClasses = c("factor", "factor"))
### Replacing the activity code with labels
levels(activities$activity) = levels(act.label[ , 2])
remove(act.label)
```

### Merging various dataframes
The final data is put together, starting with the subject, activity undertaken, and the measurements.
```
mergeddata = data.frame(subject, activities, features)
remove(subject, activities, features)
```

### Selecting only the mean and std variables
All variables that are the mean and standard deviation contain the substring "mean()" and "std()" respectively. As such, `grepl` was used to identify the columns these substrings were present. The first two were "subject", and "activity" which should be retained (as such, manually set to `TRUE()`). Following which, the `mergeddata` dataframe was subsetted to only contain the subject, activity, and measurements that are mean and standard deviation of the raw data. This completes the first portion.
```
col.select = grepl("mean()", colnames(mergeddata)) | grepl("std()", colnames(mergeddata))
col.select[1:2] = c(TRUE, TRUE)
mergeddata = mergeddata[, col.select]
remove(col.select)```
```
## Transformations for Point 5
Load the `dplyr` package for this section. The data is grouped by the subject, and activity. Following which, the `summarise_each` function was used - this applies the same function (here the `mean`) across every column, generating the desired dataset. The data is then written out to a "txt" file, was parameter `row.names = FALSE`.
```
library(dplyr)
dataset2 = mergeddata %>% group_by(subject, activity) %>%
  summarise_each(funs(mean))
write.table(dataset2, "q5.txt", row.names = FALSE)
```
