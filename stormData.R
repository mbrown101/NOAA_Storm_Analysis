##Analyis of NOAA Weather Data
Author: Michael Brown  
Date: 20 September, 2014

###Synopsis:  
NOAA Storm Data was analyized for the period 1950 to 2011 to determine if there were events that had frequent and disporportionally high effect on human health and the economy of the United States.  As it pertains to human health (measured by both injuries and fatailities), tornado events were found to have the highest impact on human health by an order of magnitude of the next most prevalent weather event, excessice heat.  As it pertains economic impact, tornados also had the hightest overall impact as measured by qumulative impact on property and crops.  The single highest impact to cropps, however was find to be flooding.  It is noted that the economic impacts of human health outcomes resultign from weather events are not captured and may have a significant effect in some cases.   

###Loading and Processing the Raw Data  
Data describing various characteristics of storm data was obtained from NOAA for years  1950 - 2011. 


```{r echo=FALSE, results='hide', message=FALSE }

# define working directory, create if it does not exist and set working directory
workingDir <- "C:/Users/Mike/Documents/R/NOAA_Storm_Data"

if (!file.exists(workingDir)){
    dir.create(file.path(workingDir))
}

setwd(workingDir)

#install.packages("timeDate")
library('timeDate')

#install.packages("ggplot2")
library('ggplot2')

#install.packages("R.utils")
library('R.utils')

#install.packages("reshape")
library('reshape')

### Loading and preprocessing the data ###

# import and unzip data
#url <- 'https://d396qusza40orc.cloudfront.net/repdata%2Fdata%2FStormData.csv.bz2'
#download.file(url , paste(getwd() , "/repdata-data-StormData.csv.bz2" , sep = '' ))
#bunzip2(paste(getwd() , "/repdata-data-StormData.csv.bz2" , sep = '' ) , overwrite = TRUE)

```


####Read in raw NOAA data

We first read in the data to a dataframe, then ensure valid column names. The data was read from a raw zipped .csv file provided by NOAA.  Content was allowed to be read in as a factor as the default case. 


```{r}
# preprocess data
raw.data <- as.data.frame(read.csv(paste(getwd() , "/repdata-data-StormData.csv" , sep = '' )))
colnames(raw.data) <- make.names(colnames(raw.data) , allow_ = FALSE)

```


After reading in, we examine top few records to check for consistency.


```{r}
head(raw.data)
```


####Scaling property damage values

Since the damage figures {PROPDMG and CROPDMG} must be modified by an exponential factor {PROPDMGEXP and CROPDMGEXP}, we check the continuity of each which should be {K , M , B}:  

Property Damage Levels:

```{r}

levels(raw.data[,'PROPDMGEXP'])


```

Crop Damage Levels:

```{r}

levels(raw.data[,'CROPDMGEXP'])

```


In order to resolve the scaling inconsistencies and to accomodate ease of scaling, we will create a new dataframe ' data' and add a new column 'damage.scale.crop' and 'damage.scale.prop' which contains a numeric scaling factor:

 { k , K } = 1000  
 { m , M } = 1000000  
 { b , B } = 1000000000  


```{r}

data <- raw.data
data$damage.scale.crop <- 0      # create initial damage.scale.crop column
data$damage.scale.prop <- 0      # create initial damage.scale.prop column

data$damage.scale.crop[data$CROPDMGEXP %in% c('k' , 'K')] <- 1000
data$damage.scale.crop[data$CROPDMGEXP %in% c('m' , 'M')] <- 1000000
data$damage.scale.crop[data$CROPDMGEXP %in% c('b' , 'B')] <- 1000000000

data$damage.scale.prop[data$PROPDMGEXP %in% c('k' , 'K')] <- 1000
data$damage.scale.prop[data$PROPDMGEXP %in% c('m' , 'M')] <- 1000000
data$damage.scale.prop[data$PROPDMGEXP %in% c('b' , 'B')] <- 1000000000

```

Now create columns prop.dam and crop.dam to reflect the scaled damage (e.g. damage.scale.prop * PROPDMG)   

```{r}
data$prop.dam <- data$damage.scale.prop * data$PROPDMG
data$crop.dam <- data$damage.scale.crop * data$CROPDMG

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

Damage to crops and property is developed in a fashon similar to the human health analysis, however, we must first modify damage figures for exponential factor in PROPDMGEXP and CROPDMGEXP respectively. In order to improve processing efficiency, we subset for records with crop or property damage greater than zero  

```{r}



```

With damage figures now properly scaled, we now aggregate crop and property damage over the study period for each event type.

```{r}

# aggregate crop damage by event type
econ.crop <- aggregate(crop.dam ~ EVTYPE , data = data , FUN = sum)      
econ.prop <- aggregate(prop.dam ~ EVTYPE , data = data , FUN = sum) 
```
The two economic impact data sets (property damage and crop damage) are first merged then totaled for each event type (e.g. the sum of crop damage and property damage) for each event. The data are then subsetted for the cases where the total economic damage isi greater than the mean. The resulting subset is then melted to accomodate plotting.

```{r}
econ <- merge(econ.crop , econ.prop , by = 'EVTYPE') 
econ$total <- econ$crop.dam + econ$prop.dam
econ.subset <- subset(econ , econ$total > mean(econ$total))
econ.melt <- melt(econ.subset[,1:3] , id = c('EVTYPE'))
```

##  Results

#### Human Health:
As shown in the plot below, across the United States, tornadoes pose the greatest impact to human health.  

```{r}

health.plot <- ggplot(data = human.health.melt , aes(x = reorder(EVTYPE , -value) , y = value , fill = variable)) +
                    geom_bar(stat = 'identity' ,  color = 'black') +  
                    ggtitle("Weather Impact to Human Health") + 
                    theme(plot.title = element_text(lineheight=.8, face="bold")) + 
                    theme(axis.text.x=element_text(angle=60, hjust=1, size = 8)) + 
                    labs(x = 'Event Type' , y = 'Total Incidents 1950 - 2011')

print(health.plot)

```

#### Economic impact:
As shown in the plot below, across the United States, floods present the greatest economic impact to crops and property and, in fact, represent greter econnmic impact to the second and third catastrophies combined (hurricanes & tornados).



```{r}
econ.plot <- ggplot(data = econ.melt , aes(x = reorder(EVTYPE , -value) , y = value , fill = variable)) +
                    geom_bar(stat = 'identity' ,  color = 'black') +  
                    ggtitle("Weather Impact to Economy") + 
                    theme(plot.title = element_text(lineheight=.8, face="bold")) + 
                    theme(axis.text.x=element_text(angle=60, hjust=1, size = 8)) + 
                    labs(x = 'Event Type' , y = 'Total Economic Impact 1950 - 2011')

print(econ.plot)
```

The top five catastrophies are shown below ordered by total damage


```{r}

head(econ.subset[ with(econ.subset, order(-total)), ] , 5)


```

Ordering by damage to propoerty only, the results are the same as shown below.

```{r}

head(econ.subset[ with(econ.subset, order(-prop.dam)), ] , 10)

```

However, when ordered by crop damage, the most significant economic damage ironically is attributable to droughts.

```{r}

head(econ.subset[ with(econ.subset, order(-crop.dam)), ] , 5)


```


## References
NOAA description of data: https://d396qusza40orc.cloudfront.net/repdata%2Fpeer2_doc%2Fpd01016005curr.pdf
data Frequently Asked Questions (FAQs): https://d396qusza40orc.cloudfront.net/repdata%2Fpeer2_doc%2FNCDC%20Storm%20Events-FAQ%20Page.pdf
