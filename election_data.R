.libPaths("C:/Program Files/R/R-3.4.1patched")
setwd("K:/DataServices/Datasets/Civic Vitality and Governance/Election Results/State_election_enrollment/Analysis/output")

rm(list=ls())
list.files()
temp=list.files(pattern=".xls")
colnames=c("muni_id","year","municipal","voters","democrat",
           "republican","green_rainbow","united_party","unenrolled","liberetarian")
library(readxl)


read_file <- lapply(temp,function(i){
  read_excel(i,col_names = T,sheet="output")
})
library(data.table)
read_file<-rbindlist(read_file)
names(read_file)<-colnames


postgres_insert<-function(schemename,tablename,data)
{  
  library("RPostgreSQL", lib.loc="C:/Program Files/R/R-3.4.1patched")
  drv<-dbDriver("PostgreSQL")
  
  con <- dbConnect(drv, dbname="postgres",host="localhost",port=5432,user = "postgres",
                   password = "Micromax@123")
  dbWriteTable(con,c(schemename,tablename), data,append=TRUE,row.names=FALSE)
  dbDisconnect(con)
  dbUnloadDriver(drv)
  detach("package:RPostgreSQL", unload=TRUE)
}  
postgres_insert("tabular","election_data",read_file)

# allcons<-dbListConnections(PostgreSQL())
# for(con in allcons)
#      dbDisconnect(con)

#CREATE TABLE tabular.election_data
#(
#  --seq_id integer NOT NULL DEFAULT nextval('tabular.educ_dropouts_by_year_districts_seq'::regclass),
#  muni_id numeric,
#  year numeric,
#  municipal character varying(100),
#  voters numeric,
#  democrat numeric,
#  republican numeric,
#  green_rainbow numeric,
#  united_party numeric,
#  unenrolled numeric,
#  liberetarian numeric
#)
#WITH (
#  OIDS=FALSE
#);