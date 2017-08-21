.libPaths("C:/Program Files/R/R-3.4.1patched")
setwd("K:/DataServices/Datasets/U.S. Census and Demographics/GeoLytics/1970_2010/Data/Analysis")

rm(list=ls())
list.files()
#install.packages("readxl")
library(readxl)  #Package to Read data xlsx
#######READING DATA #################
#install.packages("reshape2")
library(reshape2)
data1970<-read_excel("1970.xlsx",col_names = T,skip=0,sheet="1970")
data1970<-melt(data1970,id=c("GEO2010","years"))
data1980<-read_excel("1980.xlsx",col_names = T,skip=0,sheet="1980")
data1980<-melt(data1980,id=c("GEO2010","years"))
data1990<-read_excel("1990.xlsx",col_names = T,skip=0,sheet="1990")
data1990<-melt(data1990,id=c("GEO2010","years"))
data2000<-read_excel("2000.xlsx",col_names = T,skip=0,sheet="2000")
data2000<-melt(data2000,id=c("GEO2010","years"))

data<-rbind(data1970,data1980,data1990,data2000)
###### Support_data file : Create a file with the alais name as needed ##also give categories as per the table name needed
support_data<-read.csv("neighbourhood.txt",sep="\t",header = TRUE)

categories<-unique(support_data$category)
cate<-gsub(" |/","_",categories)
data1<-data[0,]
data2<-data[0,]
data3<-data[0,]

for(i in 1:length(categories))
{
  ##q1 means Query 1 pi means part 1##
  library("sqldf", lib.loc="C:/Program Files/R/R-3.4.1patched")
  q1p1<- paste0("SELECT * FROM data where VARIABLE like '",support_data$col_name[which(support_data$category==categories[i])[1]],"'")
  q1p2<-""
  for(j in which(support_data$category==categories[i])[-1])
  {
    q1p2<-paste0(qp2,"\n\t\t OR VARIABLE LIKE \"",support_data$col_name[j],"\"")
  }
  q1<-paste0(q1p1,q1p2)
  data1<-sqldf(q1)
  #levels(data1$variable)
  #it shows original number of levels 4525  in column variable .when there are only 7 distinct levels.To change that
  #3 line following code
  a <- sapply(data1, is.factor)#get the position of intended column as a boolean vector
  data1[a] <- lapply(data1[a], as.character)
  data1[a] <- lapply(data1[a], as.factor)
  #levels(data1$variable)
  q2p1<-"Select GEO2010,years,\n\t CASE "
  q2p2<-""
  count=0
  for(j in which(support_data$category==categories[i]))
  {
    q2p2<-paste0(q2p2,"\n\t\t WHEN VARIABLE LIKE \"",support_data$col_name[j],"\" THEN \"",support_data$alais_name[j],"\"")
  }
  q2p3<-"\n Else 'none' \n \t \t END category, \n \t\t CASE"
  q2p4<-""
  for(j in which(support_data$category==categories[i]))
  {
    q2p4<-paste0(q2p4,"\n\t\t WHEN VARIABLE LIKE \"",support_data$col_name[j],"\" THEN \"",support_data$desc[j],"\"")
  }
  q2p5<-"\n Else 'none' \n \t \t END desc, \n \t\t variable,value from data1"
  q2<-paste0(q2p1,q2p2,q2p3,q2p4,q2p5)
  data2<-sqldf(q2)
  meta<-sqldf("SELECT distinct category,desc,variable from data2")
  data2<-data2[,c("GEO2010","years","category","value")]
  data3<- dcast(data2,formula=GEO2010 + years ~ c(category),value.var="value")
  postgres_insert("tabular",cate[i],data3)
  detach("package:sqldf", unload=TRUE)
  filename_meta<-paste0("K:/DataServices/Datasets/U.S. Census and Demographics/GeoLytics/1970_2010/Data/Analysis/census_requested_",cate[i],"_meta.csv")
  #write.csv(data2,filename_data2,row.names = F)
  write.csv(meta,filename_meta,row.names = F)
  #sink("q2.sql",append = FALSE)
  #cat(q2)
  #sink()
}

##TESTQUERIES#################
###sqldf("SELECT alais_name,COUNT(*) A FROM support_data group by alais_name having A>1")
###  alais_name A
###1     ownocc 2
###2     rntocc 2
###3     wrcnty 2
###sqldf("SELECT col_name,alais_name,COUNT(*) A FROM support_data group by alais_name,col_name having A>1")
###  col_name alais_name A
###1  OWNOCC9     ownocc 2
###2  RNTOCC9     rntocc 2
###3 WRCNTY9D     wrcnty 2
##############THE above two queries should return same amount of rows. If former returns more rows than latter 
#######then there are duplicate alais names in support_data. The duplicates can be found in above queries.
##########ALSO CREATE TABLE NAMES WITH CORRECT COLUMN NAMES IN POSTGRES and pass the right schemaname and tablename to postgres insert function
####The table names can be stored in the right order in cate vector.

postgres_insert<-function(schemename,tablename,data)
{  
  library("RPostgreSQL", lib.loc="C:/Program Files/R/R-3.4.1patched")
  drv<-dbDriver("PostgreSQL")
  
  con <- dbConnect(drv, dbname="postgres",host="localhost",port=5432,user = "postgres",
                   password = "Micromax@123")
  dbWriteTable(con,c(schemename,tablename), data)
  dbDisconnect(con)
  dbUnloadDriver(drv)
  detach("package:RPostgreSQL", unload=TRUE)
}  
#lapply(dbListConnections(dbDriver("PostgreSQL")), dbDisconnect)
