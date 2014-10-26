Course Project for Coursera "Getting and Cleaning Data" course
==============================================================

This is the course project for the [Coursera "Getting and Cleaning Data" course](https://class.coursera.org/getdata-008)

The purpose of the project is to create an R script that combines the given sets of accelerometer data, selects a subset of the overall data and presents it in a more usable format.

The script is called run_analysis.R

The data was provided [as a zip file](https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip) and more information about how it was collected is available on the [associated website](http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones) and in the file `readme.txt` which is included in the downloadable zip file.

There is [a Codebook](Codebook.md) that describes the format of the resulting data and the steps taken in order to process it.

How the script works
--------------------

The core function is called runAnalysis. Running this function will return the final data set as described in the Codebook.

Within this function, there are a number of distinct subsections for handling each step of the processing as well as some utility functions and configuration settings to make amendments easier in the future.

### Configuration

There is a single configuration variable set at the start of the script called `dataFolder`. This is the folder in which the original data can be found. It is assumed that within this folder is the original data as downloaded from the above link.

### Utility functions

There is a single utility function called `loadDataFromFile`. This loads the data from the specified file within the data folder. The first argument should be the relative path to the file. The remaining arguments will be passed on to R's `read.table` method.

### Combining the different parts of the data set

The original data contains data for two groups - the 'train' group and the 'test' group. The data for each of these groups is then split across 3 files. They are

- `<group>/subject_<group>.txt` : The subject for each measurement
- `<group>/y_<group>.txt`       : The activity id for each measurement
- `<group>/X_<group>.txt`       : A set of accelerometer data for each measurement consisting of 561 variables per measurement

The script combines these first by creating a single data set for each group. The activity id is in the first column, the subject id in the second. The remaining columns are the accelerometer data.

The the two 2 groups are joined together. The data for the 'test' group is first, followed by the data for the 'train' group.

### Selecting the interesting subset of the data

The brief states that we are only interested in the measurements on the mean and standard deviation. This has been interpreted as being only the mean and standard deviations of the feature vectors listed in the file `features_info.txt` which is included in the original download. The interesting columns are selecting by performing a regular expression match against the column names. This regular expression is stored in the variable `interestingColumnRegex` which is defined as part of the `interestingFeatureColumnIndexes` function therefore is straightforward to change if the definition of the data we are interested in changes.

### Replacing the activity ids with meaningful labels

There are descriptions of the 6 different activities in the `activity_labels.txt` file that is part of the original download. This part of the script replaces the activity ids with the associated values from this file.

### Apply meaningful column names to the data

This uses our knowledge of how the data was combined along with the information in the 'features.txt' file to add descriptive labels to each of the columns. These names were not compliant with the normal R $ syntax therefore parentheses were stripped and hypens replaced with underscores.

### Calculate averages

Finally we calculate the average of each of the feature data for each subject / activity combination.

