.libPaths("C:/Program Files/R/R-3.4.1patched")
setwd("K:/DataServices/Datasets/Education/SchoolDistricts/Enrollment/Raw Files")

rm(list=ls())
list.files()
#install.packages("readxl")
library(readxl)  #Package to Read data xlsx
s<-4 # skiprows for enrollment raw data
#######READING GENDER DATA #################
enrol_grade_2016_17<-read_excel("DistrictEnrollmentByGrade.xlsx",col_names = T,skip=s,sheet="2016-17")
enrol_grade_2016_17$schoolyear<-'2016-17'
enrol_race_2016_17<-read_excel("DistrictEnrollmentByRaceGender.xlsx",col_names = T,skip=s,sheet="2016-17")
enrol_selecpopul_2016_17 <- read_excel("DistrictEnrollmentBySelectPop.xlsx",col_names = T,skip=s,sheet="2016-17")
enrol_selecpopul_2016_17<-enrol_selecpopul_2016_17[-1,] #remove first row as sheet had merged cells

library(sqldf)
enrol_grade_2016_17<- sqldf("SELECT `District` as name,
                            `ORG CODE` as schid,
                            `schoolyear` as schoolyear,
                            `TOTAL` as enrolled,
                            `PK` as grade_pk,
                            `K` as grade_k,
                            `1` as grade_1,
                            `2` as grade_2,
                            `3` as grade_3,
                            `4` as grade_4,
                            `5` as grade_5,
                            `6` as grade_6,
                            `7` as grade_7,
                            `8` as grade_8,
                            `9` as grade_9,
                            `10` as grade_10,
                            `11` as grade_11,
                            `12` as grade_12,
                            `SP` as grade_sp
                            FROM enrol_grade_2016_17")


enrol_race_2016_17<-sqldf("SELECT
                          `District` as name,
                          `ORG CODE` as schid,
                          `African American` as aa_pct,
                          `Asian` as as_pct,
                          `Hispanic` as lat_pct,
                          `White` as whi_pct,
                          `Native American` as na_pct,
                          `Native Hawaiian, Pacific Islander` as pi_pct,
                          `Multi-Race, Non-Hispanic` as mult_pct_pct,
                          `Males` as male_pct,
                          `Females` as fem_pct
                          FROM 
                          enrol_race_2016_17")
library("stringr")
enrol_race_2016_17$schid<-str_trim(enrol_race_2016_17$schid,"left")



enrol_selecpopul_2016_17<-sqldf("SELECT 
                                `District` as name,
                                `ORGCODE` as schid,
                                `First Language Not English` as lep_num,
                                `X__1` as lep_pct,
                                `English Language Learner` as ell_num,
                                `X__2` as ell_pct,
                                `Students With Disabilities` as swd_num,
                                `X__3` as swd_pct,
                                `High Needs` as hn_num,
                                `X__4` as hn_pct,
                                `Economically Disadvantaged` as disadv_num,
                                `X__5` as disadv_pct
                                FROM enrol_selecpopul_2016_17")

a<-sqldf("select * from enrol_grade_2016_17 Join enrol_race_2016_17  using(schid) ")

df<-merge(x=enrol_grade_2016_17,y=enrol_race_2016_17,by.x ="schid",by.y="schid",all=TRUE)

#copying Null values of left table from the right table columns and removing the common columns
#df[is.na(df$schid.x),"schid.x"]<-df[is.na(df$schid.x),"schid.y"]
df[is.na(df$name.x),"name.x"]<-df[is.na(df$name.x),"name.y"]
names(df)[names(df) == 'name.x']<-"name"
df<-df[,!(names(df) %in% c("name.y"))]

df<- sqldf("SELECT
           `schid`,`name`, `schoolyear`,`enrolled`,`grade_pk`,`grade_k`,`grade_1`,     
           `grade_2`,`grade_3`,`grade_4`,`grade_5`,`grade_6`,`grade_7`,`grade_8`,   
           `grade_9`,`grade_10`,`grade_11`,`grade_12`,`grade_sp`,
           `aa_pct`*`enrolled`/100 as aa_num,
           `aa_pct`,
           (`as_pct`*`enrolled`/100) as as_num,
           `as_pct`,    
           `lat_pct`*`enrolled`/100 as lat_num,  
           `lat_pct`,
           `whi_pct`*`enrolled`/100 as whi_num,
           `whi_pct`,
           `na_pct`*`enrolled`/100 as na_num,
           `na_pct`,
           `pi_pct`*`enrolled`/100 as pi_num,
           `pi_pct`,
           `mult_pct_pct`*`enrolled`/100 as mult_pct_num,
           `mult_pct_pct`,
           `male_pct`*`enrolled`/100 as male_num,
           `male_pct`,
           `fem_pct`*`enrolled`/100 as fem_num,
           `fem_pct`    
           FROM
           df")

df<-merge(x=df,y=enrol_selecpopul_2016_17,by.x ="schid",by.y="schid",all=TRUE)
df[is.na(df$name.x),"name.x"]<-df[is.na(df$name.x),"name.y"]
names(df)[names(df) == 'name.x']<-"district"
df<-df[,!(names(df) %in% c("name.y"))]

write.csv(df,"K:/DataServices/Datasets/Education/SchoolDistricts/Enrollment/Analysis/enrollment_by_gender_race_ethnicity_dis.csv",
          row.names = F)
#enrollment_2016_17<-read_excel("ClassSize_byGender_SpecPop_2015_16.xlsx",col_names = T,skip=5)
#enrollment_2016_17<-read_excel("ClassSize_byGender_SpecPop_2010_11.xlsx",col_names = T,skip=5)
#enrollment_2016_17<-read_excel("ClassSize_byGender_SpecPop_2011_12.xlsx",col_names = T,skip=5)
#enrollment_2016_17<-read_excel("ClassSize_byGender_SpecPop_2012_13.xlsx",col_names = T,skip=5)
#enrollment_2016_17<-read_excel("ClassSize_byGender_SpecPop_2013_14.xlsx",col_names = T,skip=5)