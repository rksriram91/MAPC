.libPaths("C:/Program Files/R/R-3.4.1patched")
setwd("K:/DataServices/Datasets/Education/SchoolDistricts/Enrollment/Analysis/new")
#RAW TO ANALYSIS MANUAL STEPS
# REname the three sheets as Grade, RaceGender , SelPop accordingly
# In Selpop sheet : Insert The copied row from file S in row 4 
# Move the columns to match row 4 (as we ll remove the headers row 5 ,6 in next step, not necessary for years before 201314 i guess)
# Remove row 5 ad 6
# insert two more rows before row 4 so that we skip exactly 4 rows before reading the colheaders of the data
rm(list=ls())
list.files()
library(readxl)
#dese_meta<-read_excel("K:/DataServices/Datasets/Education/Schools/Enrollment/Analysis/DESE_meta_table.xlsx",
#                      col_names= T,sheet="Sheet1")
library(sqldf)
#colnames_db_grade<-as.vector(sqldf("Select DB_COLNAMES from dese_meta WHERE DOMAIN='Enrollment' 
#                        and type='DISTRICT' and Raw_sheet_names = 'Grade' and is_raw_present=1 ORDER BY Raw_Order")[['DB_COLNAMES']])
#colnames_db_raceGender<-as.vector(sqldf("Select DB_COLNAMES from dese_meta WHERE DOMAIN='Enrollment' 
#                        and type='DISTRICT' and Raw_sheet_names = 'RaceGender' and is_raw_present=1 ORDER BY Raw_Order")[['DB_COLNAMES']])
#colnames_db_selpop<-as.vector(sqldf("Select DB_COLNAMES from dese_meta WHERE DOMAIN='Enrollment' 
#                        and type='DISTRICT' and Raw_sheet_names = 'SelPop' and is_raw_present=1 ORDER BY Raw_Order")[['DB_COLNAMES']])

years<-list('2005-06','2006-07','2007-08','2009-10',
  '2010-11','2011-12','2012-13','2013-14','2014-15','2015-16','201617')

filenames <- list.files(pattern='DisEnroll_')
read_file_grade <- function(x,year) {
  dat_grade<-read_excel(x, col_names=TRUE,skip=4,sheet = 'Grade')
  dat_grade<-melt(dat_grade, id = c("DISTRICT", "ORG CODE"))
  #dat_grade$schoolyear<-year
  return(dat_grade)
}
read_file_raceGender <- function(x) {
  dat_grade<-read_excel(x, col_names=TRUE,skip=4,sheet = 'RaceGender')
  dat_grade<-melt(dat_grade, id = c("DISTRICT", "ORG CODE"))
  return(dat_grade)
}
read_file_selPop <- function(x) {
  dat_grade<-read_excel(x, col_names=TRUE,skip=4,sheet = 'SelPop')
  dat_grade<-melt(dat_grade, id = c("DISTRICT", "ORG CODE"))
  return(dat_grade)
}

#melt_grade <- function(x) {
#melt(x, id = c("DISTRICT", "ORG CODE"))
#}  


grade<-lapply(filenames,read_file_grade)
grade<-Map(cbind, grade, year = years)
grade <- do.call(rbind,grade)

raceGender<-lapply(filenames,read_file_raceGender)
raceGender<-Map(cbind, raceGender, year = years)
raceGender <- do.call(rbind,raceGender)

selPop<-lapply(filenames,read_file_selPop)
selPop<-Map(cbind, selPop, year = years)
selPop <- do.call(rbind,selPop)

enrol<-rbind(grade,raceGender,selPop)

grade<-lapply(filenames,read_file_grade)
raceGender <- do.call(rbind,grade)

library(reshape2)	
new_enrol<-dcast(enrol,DISTRICT+`ORG CODE`+`year`~variable,value.var = 'value',fun=mean)
new_enrol[is.na(new_enrol)] <- 0
library(sqldf)
finenrol=sqldf("SELECT `ORG CODE` as districtid,
                `DISTRICT` as district,
                `year` as schoolyear,
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
               `SP` as grade_sp,
               ROUND(`African American`/100 * `TOTAL`,0) as aa_num,
               ROUND(`African American`,2) as aa_pct,
               ROUND(`Asian`/100 * `TOTAL`,0) as as_num,
               ROUND(`Asian`,2) as as_pct,
               ROUND(`Hispanic`/100 * `TOTAL`,0) as lat_num,
               ROUND(`Hispanic`,2) as lat_pct,
               ROUND(`White`/100 * `TOTAL`,0) as whi_num,
               ROUND(`White`,2) as whi_pct,
               ROUND(`Native American`/100 * `TOTAL`,0) as na_num,
               ROUND(`Native American`,2) as na_pct,
               ROUND(`Native Hawaiian, Pacific Islander`/100 * `TOTAL`,0) as pi_num,
               ROUND(`Native Hawaiian, Pacific Islander`,2) as pi_pct,
               ROUND(`Multi-Race, Non-Hispanic`/100 * `TOTAL`,0) as mult_num,
               ROUND(`Multi-Race, Non-Hispanic`,2) as mult_pct,
               ROUND(`Males`/100 * `TOTAL`,0) as male_num,
               ROUND(`Males`,2) as male_pct,
               ROUND(`Females`/100 * `TOTAL`,0) as fem_num,
               ROUND(`Females`,2) as fem_pct,
               ROUND(`First Language Not English`,0) as ell_num,
               ROUND(`First Language Not English_p`,2) as ell_pct,
               ROUND(`English Language Learner`,0) as lep_num,
               ROUND(`English Language Learner_p`,2) as lep_pct,
               ROUND(`Students With Disabilities`,0) as swd_num,
               ROUND(`Students With Disabilities_p`,2) as swd_pct,
               ROUND(`Low-Income`,0) as li_num,
               ROUND(`Low-Income_p`,2) as li_pct,
               ROUND(`Free Lunch`,0) as free_num,
               ROUND(`Free Lunch_p`,2) as free_pct,
               ROUND(`Reduced Lunch`,0) as red_num,
               ROUND(`Reduced Lunch_p`,2) as red_pct,
               ROUND(`High Needs`,0) as hn_num,
               ROUND(`High Needs_p`,2) as hn_pct,
               ROUND(`Economically Disadvantaged`,0) as ed_num,
               ROUND(`Economically Disadvantaged_p`,2) as ed_pct,
               1 as mapc FROM new_enrol")

detach(package:sqldf, unload=TRUE)
# CONNECT TO POSTGRES

library(RPostgreSQL)
drv<-dbDriver("PostgreSQL")

con <- dbConnect(drv, dbname="postgres",host="localhost",port=5432,user = "postgres",
                 password = "Micromax@123")
dbWriteTable(con,c("tabular","educ_enrollment_by_year_districts"), finenrol,overwrite=TRUE,row.names=FALSE)
#schools<- dbGetQuery(con, "SELECT distinct name,schid from tabular.Schools_2017")
detach("RPostgreSQL", unload=TRUE)