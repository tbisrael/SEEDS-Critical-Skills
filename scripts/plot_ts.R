# R script to modify data
d<-read.csv("wp.csv")  # here, we read in the data to be used
str(d)

library(dplyr)   # call in the R package containing the relevant functions for this analysis

SE<-function(x){sd(x,na.rm=T)/sqrt(length(x))}  # write a function to calculate standard error

sum_WP<-d%>%
  mutate(datetime=as.POSIXct(strptime(datetime, "%m/%d/%Y %H:%M")),  # adds new variable, while preserving the existing one in the file
         date=as.POSIXct(paste0(date," 00:00"), format="%m/%d/%Y %H:%M"))%>%  # the newly added variable, which is datetime is formatted to month, day, year, hour, and minute
  group_by(date)%>%  # then, we group the data by date
  summarize(m=mean(negWP,na.rm=T),se=SE(negWP),sd=sd(negWP))  # compute summary statistics for the data, including mean, standard deviation and standard error


#Automated data
load("../psychrometer_append/clean3/new_1b_3.r")  # here, we load a RData into the working environment and call it "new_d1"
str(new_d1)  # describe the data structure in new_d1

library(ggplot2)  # we want to plot the data, so we bring in the R package with the necessary functions
fig1<-ggplot()+  # we call the plot fig1 and ask ggplot function to create it
  geom_point(data=new_d1, aes(x=datetime, y=psy))+  # we ask the function to plotgit  a graph giving it the data source, and data to be plotted in the x and y axes
  geom_point(data=sum_WP, aes(x=date, y=m), stat="identity", size=3, col="red")+  # additional data to be included in the plot, and specifying the color and size of the points
  geom_errorbar(data=sum_WP, aes(x=date, ymin=m-sd, ymax=m+sd), stat="identity",width=5)  # error bars to be included and the function to calculate them
fig1  # print the resulting graph

