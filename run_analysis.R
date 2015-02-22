## You should create one R script called run_analysis.R that does the following. 
## 1. Merges the training and the test sets to create one data set.
## 2. Extracts only the measurements on the mean and standard deviation for each measurement. 
## 3. Uses descriptive activity names to name the activities in the data set
## 4. Appropriately labels the data set with descriptive variable names.

# Set your working directory as the folder with the Samsung dataset

### Reading the derivatives
train.features = read.table("train/X_train.txt")
test.features = read.table("test/X_test.txt")
features = rbind(train.features, test.features)
remove(train.features, test.features)

### Reading feature labels
label.features = read.table("features.txt")
colnames(features) = t(label.features[2])
remove(label.features)

### Reading the subject
train.sub = read.table("train/subject_train.txt")
test.sub = read.table("test/subject_test.txt")
subject = rbind(train.sub, test.sub)
remove(train.sub, test.sub)
colnames(subject) = "subject"

### Reading activities
train.act = read.table("train/y_train.txt", colClasses = "factor")
test.act = read.table("test/y_test.txt", colClasses = "factor")
activities = rbind(train.act, test.act)
remove(train.act, test.act)
colnames(activities) = "activity"

### Reading activity labels
act.label = read.table("activity_labels.txt", colClasses = c("factor", "factor"))
### Replacing the activity code with labels
levels(activities$activity) = levels(act.label[ , 2])
remove(act.label)

mergeddata = data.frame(subject, activities, features)
remove(subject, activities, features)

### Selecting only the mean and std
col.select = grepl("mean()", colnames(mergeddata)) | grepl("std()", colnames(mergeddata))
col.select[1:2] = c(TRUE, TRUE)
mergeddata = mergeddata[, col.select]
remove(col.select)

## 5. From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.
library(dplyr)
dataset2 = mergeddata %>% group_by(subject, activity) %>%
  summarise_each(funs(mean))
write.table(dataset2, "q5.txt", row.names = FALSE)
