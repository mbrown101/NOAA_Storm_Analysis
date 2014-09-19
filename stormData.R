---
title: "Analysis of NOAA Storm Data"
author: "Michael Brown"
date: "Friday, September 19, 2014"
output: html_document
---


### Synopsis:  
NOAA Storm Data was analyized for the period 1950 to 2011 to determine if there were events that had frequent and disporportionally high effect on human health and the economy of the United States.  As it pertains to human health (measured by both injuries and fatailities), tornado events were found to have the highest impact on human health by an order of magnitude of the next most prevalent weather event, excessice heat.  AS it pertains economic impact, tornados also had the hightest overall impact as measured by qumulative impact on property and crops.  The single highest impact to cropps, however was find to be flooding.  It is noted that the economic impacts of human health outcomes resultign from weather events are not captured and may have a significant effect in some cases.   

### Loading and Processing the Raw Data  
Data describing various characteristics of storm data was obtained from NOAA for years  1950 - 2011. 

#### Reading in the raw data
Data was read from a raw zipped .csv file provided by NOAA.  The data was in delimited format.  Content was allowed to be read in as a factor as the default case.  

```{r, echo = FALSE , hide = TRUE}

# define working directory, create if it does not exist and set working directory
workingDir <- "C:/Users/Mike/Documents/R/NOAA_Storm_Data"

if (!file.exists(workingDir)){
    dir.create(file.path(workingDir))
}

setwd(workingDir)

options(scipen = 100)

library(ggplot2)
library(R.utils)
library(reshape)

```

####Read in NOAA data

We first read in the data to a dataframe.

```{r}
# preprocess data
data <- as.data.frame(read.csv(paste(getwd() , "/repdata-data-StormData.csv" , sep = '' )))

```

After reading in, we check the structure:

```{r}
str(data)
```

Next, we aggregate injuries and fatalities across all years as a function of weather event.

```{r}
# aggregate fatailities by event type
human.life <- aggregate(FATALITIES ~ EVTYPE , data = data , FUN = sum)      

# aggregate injuries by event type
human.injury <- aggregate(INJURIES ~ EVTYPE , data = data , FUN = sum) 
```

The two data sets for human health (fataility and injury) first merged then ordered and subsetted for cases where the aggregate injuries or fatailities are greater that the mean. 

```{r}
# merge data sets
human.health <- merge(human.life , human.injury , by = 'EVTYPE')           

# order by fatality frequency
human.health.ordered <- human.health[ order(-human.health[,2] , -human.health[ ,3]) , ]

# select only events that represent injuries or fatailities greater than the mean
human.health.trim <- subset(human.health , FATALITIES > mean(FATALITIES) | INJURIES > mean(INJURIES))  
human.health.melt <- melt(human.health.trim , id = c('EVTYPE'))
```

In a fashon similar to the human health analysis, we aggregate crop and property damage over the dtudyt period for each eveny type.

```{r}

# aggregate crop damage by event type
econ.crop <- aggregate(CROPDMG ~ EVTYPE , data = data , FUN = sum)      
econ.prop <- aggregate(PROPDMG ~ EVTYPE , data = data , FUN = sum) 
```
The two economic impact data sets (property damage and crop damage) are first merged then totaled for each event type (e.g. the sum of crop damage and property damage) for each event. The data are then subsetted for the cases where the total economic damage isi greater than the mean. The resulting subset is then melted to accomodate plotting.

```{r}
econ <- merge(econ.crop , econ.prop , by = 'EVTYPE') 
econ$total <- econ$CROPDMG + econ$PROPDMG
econ.subset <- subset(econ , econ$total > mean(econ$total))
econ.melt <- melt(econ.subset[,1:3] , id = c('EVTYPE'))
```

##  Results
## Investigations:
Across the United States, which types of events (as indicated in the EVTYPE variable) are most harmful with respect to population health?

```{r}

health.plot <- ggplot(data = human.health.melt , aes(x = reorder(EVTYPE , -value) , y = value , fill = variable)) +
                    geom_bar(stat = 'identity' ,  color = 'black') +  
                    ggtitle("Weather Impact to Human Health") + 
                    theme(plot.title = element_text(lineheight=.8, face="bold")) + 
                    theme(axis.text.x=element_text(angle=60, hjust=1, size = 8)) + 
                    labs(x = 'Event Type' , y = 'Total Incidents 1950 - 2011 [log]')

print(health.plot)

```
Across the United States, which types of events have the greatest economic consequences?

```{r}
econ.plot <- ggplot(data = econ.melt , aes(x = reorder(EVTYPE , -value) , y = value , fill = variable)) +
                    geom_bar(stat = 'identity' ,  color = 'black') +  
                    ggtitle("Weather Impact to Economy") + 
                    theme(plot.title = element_text(lineheight=.8, face="bold")) + 
                    theme(axis.text.x=element_text(angle=60, hjust=1, size = 8)) + 
                    labs(x = 'Event Type' , y = 'Total Economic Impact 1950 - 2011')

print(econ.plot)
```

## References
NOAA description of data: https://d396qusza40orc.cloudfront.net/repdata%2Fpeer2_doc%2Fpd01016005curr.pdf
data Frequently Asked Questions (FAQs): https://d396qusza40orc.cloudfront.net/repdata%2Fpeer2_doc%2FNCDC%20Storm%20Events-FAQ%20Page.pdf
