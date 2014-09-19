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

install.packages("reshape")
library(reshape)

### Loading and preprocessing the data ###

# import and unzip data
url <- 'https://d396qusza40orc.cloudfront.net/repdata%2Fdata%2FStormData.csv.bz2'
download.file(url , paste(getwd() , "/repdata-data-StormData.csv.bz2" , sep = '' ))
bunzip2(paste(getwd() , "/repdata-data-StormData.csv.bz2" , sep = '' ) , overwrite = TRUE)

# preprocess data
#data <- as.data.frame(read.csv(paste(getwd() , "/repdata-data-StormData.csv" , sep = '' ) , stringsAsFactors=FALSE ))
data <- as.data.frame(read.csv(paste(getwd() , "/repdata-data-StormData.csv" , sep = '' )))
colnames(data) <- make.names(colnames(data) , allow_ = FALSE)

# remove selected columns for initial investigation
#drop.columns <- c( 'STATE..' , 'COUNTY' , 'TIME.ZONE' , 'REFNUM' , 'REMARKS' , 'BGN.AZI' , 'COUNTYENDN' , 'BGN.RANGE' , 'COUNTY.END' , 'END.RANGE' , 'END.AZI' , 'WFO' , 'STATEOFFIC')

#data <- data[,!(names(data) %in% drop.columns)]


```

## Investigations:
- Across the United States, which types of events (as indicated in the EVTYPE variable) are most harmful with respect to population health?

```{r}
# aggregate fatailities by event type
human.life <- aggregate(FATALITIES ~ EVTYPE , data = data , FUN = sum)      

# aggregate injuries by event type
human.injury <- aggregate(INJURIES ~ EVTYPE , data = data , FUN = sum) 
 
# merge data sets
human.health <- merge(human.life , human.injury , by = 'EVTYPE')           

# order by 

# select only events that represent injuries or fatailities greater than the mean
human.health.trim <- subset(human.health , FATALITIES > mean(FATALITIES) | INJURIES > mean(INJURIES))  

human.health.melt <- melt(human.health.trim , id = c('EVTYPE'))

health.plot <- ggplot(data = human.health.melt , aes(x = EVTYPE , y = value , fill = variable)) +
                    geom_bar(stat = 'identity' , position = position_dodge() , color = 'black') +  
                    ggtitle("Storm Impact to Human Health") + 
                    theme(plot.title = element_text(lineheight=.8, face="bold")) + 
                    theme(axis.text.x=element_text(angle=60, hjust=1, size = 8)) + 
                    labs(x = 'Event Type' , y = 'Total Incidents 1950 - NOV 2011')

print(health.plot)

```

- Across the United States, which types of events have the greatest economic consequences?


##  Results
Present results

.... no more than 3 figures

## References
NOAA description of data: https://d396qusza40orc.cloudfront.net/repdata%2Fpeer2_doc%2Fpd01016005curr.pdf
data Frequently Asked Questions (FAQs): https://d396qusza40orc.cloudfront.net/repdata%2Fpeer2_doc%2FNCDC%20Storm%20Events-FAQ%20Page.pdf
