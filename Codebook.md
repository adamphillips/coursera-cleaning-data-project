Codebook
========

This describes the steps taken in order to process the data.

There are more specific details about the implementation available in [the readme](README.md).

For more information see the [original download](https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip)
and the [related website](http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones)

## Resulting data format

The resulting data consists of 68 columns and 180 rows. The columns are as follows:

- ActivityDescription : The activity associated with the measurement. This is one of LAYING, SITTING, STANDING, WALKING, WALKING_DOWNSTAIRS, WALKING_UPSTAIRS
- Subject : The ID of the subject. This is a number between 1 and 30 inclusive.

The remaining 66 columns are average values for each piece of accelarometer data.

- tBodyAcc_mean_X
- tBodyAcc_mean_Y
- tBodyAcc_mean_Z
- tBodyAcc_std_X
- tBodyAcc_std_Y
- tBodyAcc_std_Z
- tGravityAcc_mean_X
- tGravityAcc_mean_Y
- tGravityAcc_mean_Z
- tGravityAcc_std_X
- tGravityAcc_std_Y
- tGravityAcc_std_Z
- tBodyAccJerk_mean_X
- tBodyAccJerk_mean_Y
- tBodyAccJerk_mean_Z
- tBodyAccJerk_std_X
- tBodyAccJerk_std_Y
- tBodyAccJerk_std_Z
- tBodyGyro_mean_X
- tBodyGyro_mean_Y
- tBodyGyro_mean_Z
- tBodyGyro_std_X
- tBodyGyro_std_Y
- tBodyGyro_std_Z
- tBodyGyroJerk_mean_X
- tBodyGyroJerk_mean_Y
- tBodyGyroJerk_mean_Z
- tBodyGyroJerk_std_X
- tBodyGyroJerk_std_Y
- tBodyGyroJerk_std_Z
- tBodyAccMag_mean
- tBodyAccMag_std
- tGravityAccMag_mean
- tGravityAccMag_std
- tBodyAccJerkMag_mean
- tBodyAccJerkMag_std
- tBodyGyroMag_mean
- tBodyGyroMag_std
- tBodyGyroJerkMag_mean
- tBodyGyroJerkMag_std
- fBodyAcc_mean_X
- fBodyAcc_mean_Y
- fBodyAcc_mean_Z
- fBodyAcc_std_X
- fBodyAcc_std_Y
- fBodyAcc_std_Z
- fBodyAccJerk_mean_X
- fBodyAccJerk_mean_Y
- fBodyAccJerk_mean_Z
- fBodyAccJerk_std_X
- fBodyAccJerk_std_Y
- fBodyAccJerk_std_Z
- fBodyGyro_mean_X
- fBodyGyro_mean_Y
- fBodyGyro_mean_Z
- fBodyGyro_std_X
- fBodyGyro_std_Y
- fBodyGyro_std_Z
- fBodyAccMag_mean
- fBodyAccMag_std
- fBodyBodyAccJerkMag_mean
- fBodyBodyAccJerkMag_std
- fBodyBodyGyroMag_mean
- fBodyBodyGyroMag_std
- fBodyBodyGyroJerkMag_mean
- fBodyBodyGyroJerkMag_std

## Processing

This describes the steps that were taken in order to process the original data into this form.

### Step 1: Combining the data sets

The original data contains data for two groups - the 'train' group and the 'test' group. The data for each of these groups is then split across 3 files. They are

- `<group>/subject_<group>.txt` : The subject for each measurement
- `<group>/y_<group>.txt`       : The activity id for each measurement
- `<group>/X_<group>.txt`       : A set of accelerometer data for each measurement consisting of 561 variables per measurement

The script combines these first by creating a single data set for each group. The activity id is in the first column, the subject id in the second. The remaining columns are the accelerometer data. These data sets were combined using R's `cbind` function.

The the two 2 groups are joined together. The data for the 'test' group is first, followed by the data for the 'train' group. These were combined using R's `rbind` function.

### Step 2: Selecting the interesting set of data

The interesting data is defined to be the mean and standard deviation measurements for each of the feature vectors listed in the file `features.txt` which is part of the provided data information.
In order to extract these from the origin columns a regular expression match was performed against the column names to produce a vector containing the columns to be selected from the combined data set created in Step 1.
In particularly, mean frequency and angle measurements were not included as these are not considered to be measurements on the mean or standard deviation.

### Step 3: Replacing the activity IDs with descriptive labels

Descriptive labels of each of the 6 activities were provided as part of the original data set in the file `activity_labels.txt`.
The data set created in part 2 was merged with this set of labels using R's `merge` function and then the original activity id column dropped.

### Step 4: Apply descriptive column names

The column names provided in `features.txt` were sanitised to make them compliant with R $ syntax. This involved removing parentheses and replacing hyphens with underscores.
The generic column names for the data set created in Step 3 were then replaced with this sanitised set.

### Step 5: Select average values for each activity / subject combination

R's `aggregate` function was used along with the `mean` function to calculate the average value for each activity / subject combinations.
