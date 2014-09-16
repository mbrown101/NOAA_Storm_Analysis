---
title: "Analysis of NOAA Storm Data"
author: "Mike Brown"
date: "Tuesday, September 16, 2014"
output: html_document
---

## Synopsis:  
NOAA Storm Data was analyized and was found to have ........   
describes and summarizes your analysis in at most 10 complete sentences.

## Data Processing  
describes (in words and code) how the data were loaded into R and processed for analysis. In particular, your analysis must start from the raw CSV file containing the data. You cannot do any preprocessing outside the document. If preprocessing is time-consuming you may consider using the cache = TRUE option for certain code chunks.

```{r, echo=TRUE}

# define working directory, create if it does not exist and set working directory
workingDir <- "C:/Users/Mike/Documents/R/NOAA_Storm_Data"

if (!file.exists(workingDir)){
    dir.create(file.path(workingDir))
}

setwd(workingDir)

install.packages("timeDate")
library(timeDate)

install.packages("ggplot2")
library(ggplot2)

install.packages("R.utils")
library(R.utils)

### Loading and preprocessing the data ###

# import and unzip data
url <- 'https://d396qusza40orc.cloudfront.net/repdata%2Fdata%2FStormData.csv.bz2'
download.file(url , paste(getwd() , "/repdata-data-StormData.csv.bz2" , sep = '' ))
bunzip2(paste(getwd() , "/repdata-data-StormData.csv.bz2" , sep = '' ))

# preprocess data
data <- as.data.frame(read.csv(paste(getwd() , "/repdata-data-StormData.csv" , sep = '' )))



```

##  Results
Present results

.... no more than 3 figures

```{r, echo=FALSE}
plot(cars)
```

Note that the `echo = FALSE` parameter was added to the code chunk to prevent printing of the R code that generated the plot.
