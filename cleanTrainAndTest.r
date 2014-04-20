library("data.table")
setwd('./UCI\ HAR\ Dataset')
# fread does not work properly, ugly workaround
x_test <- read.table('test/X_test.txt', header=FALSE)
x_train <- read.table('train/X_train.txt', header=FALSE)

x_test <- data.table(x_test)
x_train <- data.table(x_train)

# verify that both datasets have the same number 
# of columns (and named the same)
# ncol(x_test), ncol(x_train) would have worked as well
all.equal(names(x_test), names(x_train))

dt <- rbind(x_test, x_train)

# make the dataframes into datatables and union them into one
# data tables are quicker to deal with that data tables
# import column labels
labelList <- read.table('features.txt', header=FALSE)
labels <- as.character(labelList$V2)

# add the column headers, gives a warning, but seems to be OK
names(dt) <- c(as.character(labelList$V2))
activity_labels <- read.table('activity_labels.txt', header=FALSE)
names(activity_labels) <- c('id', 'text')

# activities
test_activity <- read.table('test/y_test.txt')
train_activity <- read.table('train/y_train.txt')

# union, test first
activity <- rbind(test_activity, train_activity)
names(activity) <- 'id'

test_subjects <- read.table('test/subject_test.txt')
train_subjects <- read.table('train/subject_train.txt')
subjects <- rbind(test_subjects, train_subjects)
names(subjects) <- 'subject_id'

# translate activity
library(dplyr)

dt <- data.table(cbind(subjects, activity, dt))

# find standard dev measures
idsStdMeanCols <- c("subject_id", "id", grep('std|mean', names(dt), value=TRUE))

# with = FALSE makes the subsetting 
# by a vector of column names work
dt_subset <- dt[, idsStdMeanCols , with=FALSE]
dt_subset <- inner_join(dt_subset, activity_labels)
write.csv(dt_subset, './../tidy_data.csv', row.names = FALSE )


