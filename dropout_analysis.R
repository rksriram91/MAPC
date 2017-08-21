.libPaths("C:/Program Files/R/R-3.4.1patched")
setwd("K:/DataServices/Datasets/Education/SchoolDistricts/Dropout/Raw")

rm(list=ls())
list.files()
#install.packages("readxl")
library(readxl)  #Package to Read data xlsx
s<-6 
cols<-c("name","schid","num",
        "drp",
        "drp_p",
        "drp9p",
        "drp10p",
        "drp11p",
        "drp12p")
for(i in c("2015-16"))
{
  excel_file_name<-paste0("Dropout_Rates_",j,"_")
dropoutall_2015_16<-read_excel("Dropout_Rates_2016_Districts.xlsx",col_names = cols,skip=s,sheet="ALL")
dropoutall_2015_16$category<-"all"
dropoutall_2015_16$schoolyear<-i
dropoutaa_2015_16<-read_excel("Dropout_Rates_2016_Districts.xlsx",col_names = cols,skip=s,sheet="AA")
dropoutaa_2015_16$category<-"aa"
dropoutas_2015_16<-read_excel("Dropout_Rates_2016_Districts.xlsx",col_names = cols,skip=s,sheet="AS")
dropoutas_2015_16$category<-"as"
dropoutlat_2015_16<-read_excel("Dropout_Rates_2016_Districts.xlsx",col_names = cols,skip=s,sheet="LAT")
dropoutlat_2015_16$category<-"lat"
dropoutwhi_2015_16<-read_excel("Dropout_Rates_2016_Districts.xlsx",col_names = cols,skip=s,sheet="WHI")
dropoutwhi_2015_16$category<-"whi"
dropoutell_2015_16<-read_excel("Dropout_Rates_2016_Districts.xlsx",col_names = cols,skip=s,sheet="ELL")
dropoutell_2015_16$category<-"ell"
dropouted_2015_16<-read_excel("Dropout_Rates_2016_Districts.xlsx",col_names = cols,skip=s,sheet="ED")
dropouted_2015_16$category<-"ed"
dropouthn_2015_16<-read_excel("Dropout_Rates_2016_Districts.xlsx",col_names = cols,skip=s,sheet="HN")
dropouthn_2015_16$category<-"hn"
dropoutfem_2015_16<-read_excel("Dropout_Rates_2016_Districts.xlsx",col_names = cols,skip=s,sheet="fem")
dropoutfem_2015_16$category<-"fem"
dropoutmale_2015_16<-read_excel("Dropout_Rates_2016_Districts.xlsx",col_names = cols,skip=s,sheet="Male")
dropoutmale_2015_16$category<-"male"	

data1<-rbind(dropoutall_2015_16,dropoutaa_2015_16,dropoutas_2015_16,dropoutlat_2015_16,dropoutwhi_2015_16,dropoutell_2015_16,dropouted_2015_16,dropouthn_2015_16,dropoutfem_2015_16,dropoutmale_2015_16)	

library(reshape2)
library(data.table)
a<-c("num","drp",
                 "drp_p",
                 "drp9p",
                 "drp10p",
                 "drp11p",
                 "drp12p")
data2<-dcast(setDT(data1),formula= name+schid+schoolyear ~ category,
             value.var = a)
}
library(sqldf)


write.csv(data2,"K:/DataServices/Datasets/Education/SchoolDistricts/Dropout/Analysis/dropout.csv",row.names = FALSE)
