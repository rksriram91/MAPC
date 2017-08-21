.libPaths("C:/Program Files/R/R-3.4.1patched")
setwd("K:/DataServices/Datasets/Education/SchoolDistricts/Graduation_Rates/Raw")
#path=""
#filename=""
#filen <- ""
#sheetn <- ""
#colnames_db<-""
#colnames_excel<-""
#tablename<-""
#domain<-"Enrollment"
#
#if(domain<-"Enrollment")
#{
#	numTabsExcel<-3
#	tabNames<-c("RaceGender","
#	

#query(paste0("INSERT INTO" tablename "\n\t",paste0(colnames_excel, " as ",colnames_db,sep=",\n",collapse=""),"FROM df"))


#readLines(paste0(DIRPATH,"/",filename[i]))
rm(list=ls())
list.files()
#install.packages("readxl")
library(readxl)  #Package to Read data xlsx
s<-8 
cols<-c("name","schid","num",
        "grad_p",
        "stay_p",
        "ngrd_p",
        "ged_p",
        "drop_p",
        "excl_p")
gradrateall_2015_16<-read_excel("GradRate2006_schools.xlsx",col_names = cols,skip=s,sheet="All")
gradrateall_2015_16$category<-"all"
gradrateaa_2015_16<-read_excel("GradRate2006_schools.xlsx",col_names = cols,skip=s,sheet="AA")
gradrateaa_2015_16$category<-"aa"
gradrateas_2015_16<-read_excel("GradRate2006_schools.xlsx",col_names = cols,skip=s,sheet="AS")

gradrateas_2015_16$category<-"as"
gradratelat_2015_16<-read_excel("GradRate2006_schools.xlsx",col_names = cols,skip=s,sheet="LAT")
gradratelat_2015_16$category<-"lat"
gradratewhi_2015_16<-read_excel("GradRate2006_schools.xlsx",col_names = cols,skip=s,sheet="WHI")
gradratewhi_2015_16$category<-"whi"
gradrateell_2015_16<-read_excel("GradRate2006_schools.xlsx",col_names = cols,skip=s,sheet="ELL")
gradrateell_2015_16$category<-"ell"
gradrateli_2015_16<-read_excel("GradRate2006_schools.xlsx",col_names = cols,skip=s,sheet="LI")
gradrateli_2015_16$category<-"li"
gradratefem_2015_16<-read_excel("GradRate2006_schools.xlsx",col_names = cols,skip=s,sheet="Fem")
gradratefem_2015_16$category<-"fem"
gradratemale_2015_16<-read_excel("GradRate2006_schools.xlsx",col_names = cols,skip=s,sheet="Male")
gradratemale_2015_16$category<-"male"	

data1<-rbind(gradrateall_2015_16,gradrateaa_2015_16,gradrateas_2015_16,
             gradratelat_2015_16,gradratewhi_2015_16,gradrateli_2015_16,gradrateell_2015_16,gradratefem_2015_16,
             gradratemale_2015_16)


library(reshape2)
library(data.table)

data2<-melt(data1, id.vars=c("name", "schid","category"))
data3<-dcast(data2,formula= name+schid~category+variable,value.var = "value")
data3<-sqldf("SELECT schid as districtid,
name as district,
      '2015-16' as schoolyear,
      all_num,
      all_grad_p,
      all_stay_p,
      all_ngrd_p,
      all_ged_p,
      all_drop_p,
      all_excl_p,
      aa_num,
      aa_grad_p,
      aa_stay_p,
      aa_ngrd_p,
      aa_ged_p,
      aa_drop_p,
      aa_excl_p,
      as_num,
      as_grad_p,
      as_stay_p,
      as_ngrd_p,
      as_ged_p,
      as_drop_p,
      as_excl_p,
      lat_num,
      lat_grad_p,
      lat_stay_p,
      lat_ngrd_p,
      lat_ged_p,
      lat_drop_p,
      lat_excl_p,
      whi_num,
      whi_grad_p,
      whi_stay_p,
      whi_ngrd_p,
      whi_ged_p,
      whi_drop_p,
      whi_excl_p,
      ell_num,
      ell_grad_p,
      ell_stay_p,
      ell_ngrd_p,
      ell_ged_p,
      ell_drop_p,
      ell_excl_p,
      li_num,
      li_grad_p,
      li_stay_p,
      li_ngrd_p,
      li_ged_p,
      li_drop_p,
      li_excl_p,
      fem_num,
      fem_grad_p,
      fem_stay_p,
      fem_ngrd_p,
      fem_ged_p,
      fem_drop_p,
      fem_excl_p,
      male_num as mal_num,
      male_grad_p as mal_grad_p,
      male_stay_p as mal_stay_p,
      male_ngrd_p as mal_ngrd_p,
      male_ged_p as mal_ged_p,
      male_drop_p as mal_drop_p,
      male_excl_p as mal_excl_p
             from data3")
write.csv(data3,"K:/DataServices/Datasets/Education/SchoolDistricts/Graduation_Rates/Analysis/grad_rates_combined.csv",
          row.names = F)

