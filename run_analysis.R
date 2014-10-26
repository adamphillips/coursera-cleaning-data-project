runAnalysis <- function() {

    # Configuration options
    # =====================
    
    # The folder containing the original data
    # relative to the current working directoy
    dataFolder <- 'UCI HAR Dataset'
  
    # Utility functions
    # =================

    # General utitlity function for loading data from text file
    loadDataFromFile <- function(file, ...) {
      
        # Prepends the data folder to the filename
        fullFileName <- function(fileName) {
          paste(dataFolder, fileName, sep="/")
        }
    
        read.table(fullFileName(file), ...)

    } # end loadDataFromFile()

    # Part 1 - combining the different parts of the data set
    # ====================================================

    # Returns combined test and train data set
    # The first column is the subject
    # The second column is the activity
    # The remaining columns are the measured feature data
    # 
    # The test data is first followed by the training data
    combinedDataSet <- function() {
      
        # Returns the filename for the data set in the specified group
        # Eg
        # fileNameForDataSet('train', 'subject') => 'train/subject_train.txt'
        fileNameForDataSet <- function(group, dataSet) {
          paste(group, '/', dataSet, '_', group, '.txt', sep="")
        }
      
        # Returns the subject data for the specified group
        # Group can be test or train
        subjectData <- function(group) {
          loadDataFromFile(
              fileNameForDataSet(group, 'subject')
            )
        }
      
        # Returns the X data for the specified group
        # Group can be test or train
        xData <- function(group) {
          loadDataFromFile(
            fileNameForDataSet(group, 'X')
          )
        }
      
        # Returns the activity data for the specified group
        # Group can be test or train
        activityData <- function(group) {
          loadDataFromFile(
            fileNameForDataSet(group, 'y')
          )
        }
        
        # Returns the subject, activity and measured data for each of the groups
        # Group can be test or train
        combinedData <- function(group) {
          cbind(
            activityData(group),
            subjectData(group),
            xData(group)
          )
        }
        
        rbind(
          combinedData('test'),
          combinedData('train')
        )
    } # end combinedDataSet()
    

    # Part 2 - selecting the interesting subset of the data
    # ==========================================================

    # Returns the column names for all of the feature columns
    featureColumnNames <- function() {
      loadDataFromFile('features.txt')    
    }

    # Returns a vector of the interesting column indexes from the feature data
    # This is based on a regex match of the column name
    interestingFeatureColumnIndexes <- function() {
        # Regular expression to select the interesting columns
        interestingColumnRegex <- '(mean|std)\\('
      
        grep(
          interestingColumnRegex,
          featureColumnNames()[,2],
          perl=TRUE
        )    
    } # end interestingFeatureColumnIndexes

    
    # Returns a vector of the column indexes from the combined data set that we are interested in.
    # This consists of the subject, activity id and feature data
    interestingCombinedColumnIndexes <- function() {
      
      # Offset we need to apply to map the column indexes to the combined dataset
      # This is to allow for prepending other columns to the original X_... data set
      columnOffset <- 2
          
      # Applies the offset to the column indexes to allow for prepending subject and activity columns
      # Note that we still want to include those columns so we need to make sure those indexes are included
      applyOffset <- function(indexes) {
        c(
          1:columnOffset,
          indexes + columnOffset
        )      
      }
      
      applyOffset(
          interestingFeatureColumnIndexes()
        )
    } # end interestingCombinedColumnIndexes
  
    # Returns interesting columns from the combined result set
    interestingData <- function() {
      combinedDataSet()[, interestingCombinedColumnIndexes()]
    }
    
    # Part 3 - replacing the activity ids with meaningful labels
    # ==========================================================

    # Prepends the activity label to the data set
    # This loads the labels from the activity labels file and merges them with the combined data based on the activity id
    applyActivityLabels <- function(data) {
  
        # Returns the activity labels
        activityLabels <- function() {
          loadDataFromFile('activity_labels.txt',
              col.names = c('ActivityID', 'ActivityDescription')
            )
        }
        
        # Merges the two datasets
        # Note that this results in a new column being added to the dataset
        dataWithLabels <- function() {  
          merge(
            activityLabels(), data,
            by.x = 'ActivityID',
            by.y = 1,
            all.y = TRUE
          )
        }
        
        # Drops the activity id column as we don't need both the label and ID
        dropActivityID <- function(data) {
          data[2:length(data)]
        }
        
        dropActivityID(dataWithLabels())
    }

    # Part 4 - applying meaningful column names to the data
    # =====================================================
    
    # Replaces the default column names with more descriptive ones
    # For the feature data, these are the names provided in features.txt
    applyColumnNames <- function(data) {
      
      # Select just the feature names that we are interested in
      interestingFeatureColumnNames <- function() {
        as.character(
          featureColumnNames()[interestingFeatureColumnIndexes(), 2]
        )
      }
      
      # Sanitises the column names from features.txt so that they can be used
      # with the $ syntax
      sanitisedFeatureColumnNames <- function() {
        withoutParens <- gsub('\\(\\)', '', interestingFeatureColumnNames())
        convertUnderscores <- gsub('-', '_', withoutParens)
      }
      
      # Prepend the column names for data we have prepended to the feature data
      columnNames <- function() {
        c(
          'ActivityDescription',
          'Subject',
          sanitisedFeatureColumnNames()
        )
      }
      
      names(data) <- columnNames()
      data
    }

    # Generate Summaries for each activity / subject combination
    # ==========================================================
    
    generateSummaries <- function(data) {
      aggregate(
        data[3:length(data)],
        FUN="mean",
        by=list(
          ActivityDescription = data$ActivityDescription,
          Subject = data$Subject
        )
      )
    }
    
    
    
    # Putting it all together
    # =======================
    
    # This uses all of the functions above to build the overall tidy data set
    # The first 2 columns are ActivityDescription and Subject
    # The remaining columns are the average feature data for each combination
    # Each column is named based on the names in features.txt
    tidyData <- generateSummaries(
        applyColumnNames(
          applyActivityLabels(
            interestingData()
        )
      )
    )

}

#runAnalysis()
