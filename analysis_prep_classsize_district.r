#DESE data Steps
#Download years 2010-11,2011-12,2012-13,2013-14,2014-15,2015-16 from http://profiles.doe.mass.edu/state_report/classsizebygenderpopulation.aspx  and http://profiles.doe.mass.edu/state_report/classsizebyraceethnicity.aspx
#for sistricts and store it at K:/DataServices/Datasets/Education/SchoolDistricts/Class_Size/Raw

#The files are in webpage /excel97 format which is not readable. Hence convert everything to xlsx by opening and saving as xlsx in EXCEL

#then Run the following code line by line

.libPaths("C:/Program Files/R/R-3.4.1patched")
setwd("K:/DataServices/Datasets/Education/SchoolDistricts/Class_Size/Raw")

rm(list=ls())
list.files()
#install.packages("readxl")
library(readxl)  #Package to Read data xlsx
#######READING GENDER DATA #################
gender2015<-read_excel("ClassSize_byGender_SpecPop_2014_15.xlsx",col_names = T,skip=5)
gender2016<-read_excel("ClassSize_byGender_SpecPop_2015_16.xlsx",col_names = T,skip=5)
gender2011<-read_excel("ClassSize_byGender_SpecPop_2010_11.xlsx",col_names = T,skip=5)
gender2012<-read_excel("ClassSize_byGender_SpecPop_2011_12.xlsx",col_names = T,skip=5)
gender2013<-read_excel("ClassSize_byGender_SpecPop_2012_13.xlsx",col_names = T,skip=5)
gender2014<-read_excel("ClassSize_byGender_SpecPop_2013_14.xlsx",col_names = T,skip=5)

#add year values Manually
gender2011$year<-'2010-11'
gender2012$year<-'2011-12'
gender2013$year<-'2012-13'
gender2014$year<-'2013-14'
gender2015$year<-'2014-15'
gender2016$year<-'2015-16'
data<-list(gender2011,gender2012,gender2013,gender2014,gender2015,gender2016)

#install.packages("data.table")
library(data.table)
gender_school<-rbindlist(data) #bind all the year data into single dataframe
rm(data)

#######READING RACE/ETHNICITY DATA #################
eth2015<-read_excel("ClassSize_byRace_2014_15.xlsx",col_names = T,skip=5)
eth2016<-read_excel("ClassSize_byRace_2015_16.xlsx",col_names = T,skip=5)
eth2011<-read_excel("ClassSize_byRace_2010_11.xlsx",col_names = T,skip=5)
eth2012<-read_excel("ClassSize_byRace_2011_12.xlsx",col_names = T,skip=5)
eth2013<-read_excel("ClassSize_byRace_2012_13.xlsx",col_names = T,skip=5)
eth2014<-read_excel("ClassSize_byRace_2013_14.xlsx",col_names = T,skip=5)

eth2011$year<-'2010-11'
eth2012$year<-'2011-12'
eth2013$year<-'2012-13'
eth2014$year<-'2013-14'
eth2015$year<-'2014-15'
eth2016$year<-'2015-16'
datae<-list(eth2011,eth2012,eth2013,eth2014,eth2015,eth2016)

#install.packages("data.table")
#install.packages("sqldf")
library(sqldf)
library(data.table)
eth_school<-rbindlist(datae)
rm(datae)

#rm(df2)
#Adding Total number columns from percent and Renaming columns as required
gender_school<-sqldf('Select gender_school.`Org Code` as districtid,
	       gender_school.DISTRICT as district,
                     gender_school.`Total # of Classes` as tot_class,
                     gender_school.`Average Class Size` as avg_class,
                     gender_school.year as schoolyear,
                     gender_school.`Number of Students`  as n_students,
                     ROUND(gender_school.`Female %` * gender_school.`Number of Students`/100) as fem_num,
                     gender_school.`Female %` as fem_pct,
                     ROUND(gender_school.`Male %`  * gender_school.`Number of Students`/100) as male_num,
                     gender_school.`Male %` as male_pct,
                     ROUND(gender_school.`Limited English Proficient %` * gender_school.`Number of Students`/100) as lep_num,
                     gender_school.`Limited English Proficient %` as lep_pct,
                     ROUND(gender_school.`Low Income %` * gender_school.`Number of Students`/100) as li_num,
                     gender_school.`Low Income %` as li_pct
                     from gender_school ')

#Adding Total number columns from percent and Renaming columns as required
eth_school<-sqldf('SELECT 
                  eth_school.`Org Code` as districtid,
                  eth_school.DISTRICT as district,
                  eth_school.`Total # of Classes` as tot_class,
                  eth_school.`Average Class Size` as avg_class,
                  eth_school.year as schoolyear,
                  eth_school.`Number of Students`  as n_students,
                  ROUND(eth_school.`African American %` * eth_school.`Number of Students`/100) as aa_num,
                  eth_school.`African American %` as aa_pct,
                  ROUND(eth_school.`Asian %` * eth_school.`Number of Students`/100) as_num,
                  eth_school.`Asian %` as as_pct,
                  ROUND(eth_school.`Hispanic %` * eth_school.`Number of Students`/100) as lat_num,
                  eth_school.`Hispanic %` as lat_pct,
                  ROUND(eth_school.`White %` * eth_school.`Number of Students`/100) as whi_num,
                  eth_school.`White %` as whi_pct,
                  ROUND(eth_school.`Native American %` * eth_school.`Number of Students`/100) as na_num,
                  eth_school.`Native American %` as na_pct,
                  ROUND(eth_school.`Native Hawaiian, Pacific Islander %` * eth_school.`Number of Students`/100) as pi_num,
                  eth_school.`Native Hawaiian, Pacific Islander %` as pi_pct,
                  ROUND(eth_school.`Multi-Race, Non-Hispanic %` * eth_school.`Number of Students`/100) as mult_num,
                  eth_school.`Multi-Race, Non-Hispanic %` as mult_pct
                  from eth_school')
				  
				  
# Merging gender and ethnicity into single dataframe.Its a full outer join
df<-merge(x=gender_school,y=eth_school,by=c("districtid","schoolyear"),all=TRUE)

#copying Null values of left table from the right table columns and removing the common columns
df[is.na(df$district.x),"district.x"]<-df[is.na(df$district.x),"district.y"]
df[is.na(df$district.x),"tot_class.x"]<-df[is.na(df$district.x),"tot_class.y"]
df[is.na(df$district.x),"n_students.x"]<-df[is.na(df$district.x),"n_students.y"]
df[is.na(df$district.x),"avg_class.x"]<-df[is.na(df$district.x),"avg_class.y"]

#renaming the columns and removing common columns
names(df)[names(df) == 'district.x']<-"district"
names(df)[names(df) == 'tot_class.x']<-"tot_class"
names(df)[names(df) == 'avg_class.x']<-"avg_class"
names(df)[names(df) == 'n_students.x']<-"n_students"

#removing common columns
df<-df[,!(names(df) %in% c("district.y","tot_class.y","avg_class.y","n_students.y"))]
names(df)

write.csv(df,"K:/DataServices/Datasets/Education/SchoolDistricts/Class_Size/Analysis/class_size_by_gender_race_ethnicity_dis.csv",
          row.names = F)
		  
#############################################################################################################################
#############################################################################################################################
#connecting to sdevm ds database to look at existing sistrict names and use those names in the districtname column

#install.packages("RPostgreSQL")
library(RPostgreSQL)
drv<-dbDriver("PostgreSQL")
conn <- dbConnect(drv, dbname="ds",host="sdevm",port=5432,user = "viewer",
                 password = "mapcview451")

query<-"Select 
COALESCE(A.districtid,B.districtid,C.districtid,D.districtid,E.districtid,F.districtid,G.districtid,H.districtid,J.districtid,K.districtid,L.districtid),
COALESCE(A.district,B.district,C.district,D.district,E.district,F.district,G.district,H.district,J.district,K.district,L.district)
from
(SELECT districtid,district from tabular.educ_enrollment_by_year_districts where schoolyear='2016-17')A
FULL OUTER JOIN 
(SELECT districtid,district from tabular.educ_enrollment_by_year_districts where schoolyear='2015-16')B
using(districtid)
FULL OUTER JOIN 
(SELECT districtid,district from tabular.educ_enrollment_by_year_districts where schoolyear='2014-15')C
using(districtid)
FULL OUTER JOIN 
(SELECT districtid,district from tabular.educ_enrollment_by_year_districts where schoolyear='2013-14')D
using(districtid)
FULL OUTER JOIN 
(SELECT districtid,district from tabular.educ_enrollment_by_year_districts where schoolyear='2012-13')E
using(districtid)
FULL OUTER JOIN 
(SELECT districtid,district from tabular.educ_enrollment_by_year_districts where schoolyear='2011-12')F
using(districtid)
FULL OUTER JOIN 
(SELECT districtid,district from tabular.educ_enrollment_by_year_districts where schoolyear='2010-11')G
using(districtid)
FULL OUTER JOIN 
(SELECT districtid,district from tabular.educ_enrollment_by_year_districts where schoolyear='2009-10')H
using(districtid)
FULL OUTER JOIN 
(SELECT districtid,district from tabular.educ_enrollment_by_year_districts where schoolyear='2008-09')I
using(districtid)
FULL OUTER JOIN 
(SELECT districtid,district from tabular.educ_enrollment_by_year_districts where schoolyear='2007-08')J
using(districtid)
FULL OUTER JOIN 
(SELECT districtid,district from tabular.educ_enrollment_by_year_districts where schoolyear='2006-07')K
using(districtid)
FULL OUTER JOIN 
(SELECT districtid,district from tabular.educ_enrollment_by_year_districts where schoolyear='2005-06')L
using(districtid)"
school<-dbGetQuery(conn, query)

#detaching Postgres package so that it does not interfere with sqldf further
detach("package:RPostgreSQL", unload=TRUE)
colnames(school)<-c('districtid','district')

final<-merge(x=school,y=df,by="districtid",all=TRUE)
nrow(final[is.na(final$district.x),c("district.x","district.y")])

final[is.na(final$district.x),"district.x"]<-final[is.na(final$district.x),"district.y"]

names(final)[names(final) == 'district.x']<-"district"
final<-final[,!(names(final) %in% c("district.y"))]


#####################################################################################################################################
#write the final data#
write.csv(final,"K:/DataServices/Datasets/Education/SchoolDistricts/Class_Size/Analysis/class_size_by_gender_race_ethnicity_dis_new.csv",
          row.names = F)

