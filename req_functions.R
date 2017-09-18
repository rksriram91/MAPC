sqlFileAutomation <- function(domain,outfilepath,queryTables,queryTableAlaises,maxcols)
{
  outfilename<-paste0(outfilepath,"/",domain,"file",".sql")
  queryTableAlaisescols<-rep(queryTableAlaises,times=maxcols)
  
  max_cols_new<- length(queryTables)*maxcols
  type<-rep(c('e','m'),times=max_cols_new/2)
  colname<-vector(mode = "character", length = 0)
  colname_new<-vector(mode = "character", length = 0)
  
  z=1
  for(i in 1:maxcols)
  {
    for(j in 1:length(queryTables))
    {
      if(i<10) { colname[z]<-paste0(queryTableAlaisescols[z],".","_00",i) }
      else { colname[z]<-paste0(queryTableAlaisescols[z],".","_0",i) }
      z=z+1
    }
  }
  z=1
  for(i in 1:maxcols)
  {
    for(j in 1:length(queryTables))
    {
      if(i<10) { colname_new[z]<-paste0(queryTableAlaisescols[z],"00",i) }
      else { colname_new[z]<-paste0(queryTableAlaisescols[z],"0",i) }
      colname_new[z]<-gsub("_","",colname_new[z])
      z=z+1
    }
  }
  #colname<-rep(colname,each=maxcols)
  #colname_new<-rep(colname_new,each=maxcols)
  ################################################################################
  query_conditions<- c(toString(paste( "geo.mapc=1", sep='')),#352
                       toString(paste( "geo.mf=1",sep='')),#354
                       toString(paste( "geo.subregion =","'",'Inner Core (ICC) Subregion',"'", sep='')),#355
                       toString(paste( "geo.subregion =","'",'MAGIC Subregion',"'", sep='')),#356
                       toString(paste( "geo.subregion =","'",'Metrowest Subregion',"'", sep='')),#357
                       toString(paste( "geo.subregion =","'",'North Suburban (NSPC) Subregion',"'", sep='')),#358
                       toString(paste( "geo.subregion =","'",'North Shore (NSTF) Subregion',"'", sep='')),#359
                       toString(paste( "geo.subregion =","'",'South Shore (SSC) Subregion',"'", sep='')),#360
                       toString(paste( "geo.subregion =","'",'South West (SWAP) Subregion',"'", sep='')),#361
                       toString(paste( "geo.subregion =","'",'Three Rivers (TRIC) Subregion',"'", sep='')),#362
                       toString(paste( "geo.comm_type =","'",'Developing Suburb',"'", sep='')),#377
                       toString(paste( "geo.comm_type =","'",'Inner Core',"'", sep='')),#378
                       toString(paste( "geo.comm_type =","'",'Maturing Suburb',"'", sep='')),#379
                       toString(paste( "geo.comm_type =","'",'Regional Urban Center',"'", sep='')),#380
                       toString(paste( "geo.comm_type =","'",'Rural Town',"'", sep='')),#381
                       toString(paste( "geo.subtype   =","'",'Metro Core Community',"'", sep='')),#382
                       toString(paste( "geo.subtype   =","'",'Sub-Regional Urban Center',"'", sep='')),#383
                       toString(paste( "geo.subtype   =","'",'Streetcar Suburb',"'", sep='')),#384
                       toString(paste( "geo.subtype   =","'",'Mature Suburb',"'", sep='')),#385
                       toString(paste( "geo.subtype   =","'",'Established Suburb/Cape Cod Town',"'", sep='')),#386
                       toString(paste( "geo.subtype   =","'",'Maturing New England Town',"'", sep='')),#387
                       toString(paste( "geo.subtype   =","'",'Country Suburb',"'", sep='')),#388
                       toString(paste( "geo.subtype   =","'",'Major Regional Urban Center',"'", sep='')),#389
                       toString(paste( "geo.rpa_name  =","'",'Berkshire County Regional Planning Commission',"'", sep='')),#390
                       toString(paste( "geo.rpa_name  =","'",'Cape Cod Planning & Economic Development Commission',"'", sep='')),#391
                       toString(paste( "geo.rpa_name  =","'",'Central Massachusetts Regional Planning Commission',"'", sep='')),#392
                       toString(paste( "geo.rpa_name  =","'",'Franklin Regional Council of Governments',"'", sep='')),#393
                       toString(paste( "geo.rpa_name  =","'",'Marthas Vineyard Commission',"'", sep='')),#394
                       toString(paste( "geo.rpa_name  =","'",'Merrimack Valley Planning Commission',"'", sep='')),#395
                       toString(paste( "geo.rpa_name  =","'",'Montachusett Regional Planning Commission',"'", sep='')),#396
                       toString(paste( "geo.rpa_name  =","'",'Nantucket Planning & Economic Development Commission',"'", sep='')),#397
                       toString(paste( "geo.rpa_name  =","'",'Northern Middlesex Council of Government',"'", sep='')),#398
                       toString(paste( "geo.rpa_name  =","'",'Old Colony Planning Council',"'", sep='')),#399
                       toString(paste( "geo.rpa_name  =","'",'Pioneer Valley Planning Commission',"'", sep='')),#400
                       toString(paste( "geo.rpa_name  =","'",'Southeastern Regional Planning & Economic Development District',"'", sep='')),#401
                       toString(paste( "geo.region    =","'",'Central Massachusetts',"'", sep='')),#402
                       toString(paste( "geo.region    =","'",'Northeastern Massachusetts',"'", sep='')),#403
                       toString(paste( "geo.region    =","'",'Southeastern Massachusetts',"'", sep='')),#404
                       toString(paste( "geo.region    =","'",'Western Massachusetts',"'", sep='')))#405
  ###################################################################################################################					 
  s<-""
  for(i in 1:length(type))
  {
    if(type[i]=='e')
    { s=paste(s,"\n\t\tSUM(",colname[i],"::numeric) as ",colname_new[i],",",sep="")} 
    else if(type[i]=='m'&i==length(type) )	
    { s=paste(s,"\n\t\tsqrt(SUM(",colname[i],"::numeric^2)) as ",colname_new[i],sep="")}
    else{ s=paste(s,"\n\t\tsqrt(SUM(",colname[i],"::numeric^2)) as ",colname_new[i],",",sep="")}
  }
  jo<-''
  for(i in 1:length(queryTables))
  {
    jo<-paste0(jo,"\n	join ",queryTables[i]," as ",queryTableAlaises[i]," on ",queryTableAlaises[i],".logrecno = g.logrecno")
  }
  ###################################################################################################################
  
  #####################################################################################################################################
  qno<-c(352,354:362,377:405)
  ins<-vector(mode = "character", length = 0)	
  sel<-vector(mode = "character", length = 0)	
  mid<-vector(mode = "character", length = 0)	
  frm<-vector(mode = "character", length = 0)	
  jn<-vector(mode = "character", length = 0)
  fjn<-vector(mode = "character", length = 0)		
  logrec_where<-vector(mode = "character", length = 0)
  x<-vector(mode = "character", length = 0)
  if (file.exists(outfilename)) {file.remove(outfilename)}
  file.create(outfilename)
  sink(outfilename, append=TRUE, split=FALSE)
  #sink(outfilename)
  for(i in 1:length(qno))
  {
    if(i==1)
    { ins[i] <- paste0("DROP TABLE IF EXISTS acs1115.AGGRE_MUNI_ID_",domain,";\n","CREATE TABLE acs1115.AGGRE_MUNI_ID_",domain," AS")
    }
    else
    { ins[i] <- paste0("\n INSERT INTO acs1115.AGGRE_MUNI_ID_",domain)}
    
    #Select first lines
    sel[i]<-paste0("\n\tSELECT\n\t\t",qno[i]," AS agg_id,\n\t\t",qno[i]," AS muni_id,")
    mid[i]<-s
    frm[i]=	"\n from acs1115.acs_id_lookup g"
    jn[i]<-jo
    fjn[i]<-"\n  join acs1115.acs_muni_geoid geo on geo.muni_id = g.muni_id"
    logrec_where[i]<-paste0("\n where g.logrecno in 
                            (select distinct g.logrecno 
                            from acs1115.acs_id_lookup g 
                            JOIN acs1115.acs_muni_geoid geo  
                            on geo.muni_id = g.muni_id and ",query_conditions[i],");")	
    x[i]<-paste0(ins[i],sel[i],mid[i],frm[i],jn[i],fjn[i],logrec_where[i],"\n")			 
    cat(x[i])
  }				 
  sink()
}	

LINECLEAN <- function(x) {
  x = gsub("\t+", "", x, perl=TRUE); # remove all tabs
  x = gsub("^\\s+", "", x, perl=TRUE); # remove leading whitespace
  x = gsub("\\s+$", "", x, perl=TRUE); # remove trailing whitespace
  x = gsub("[ ]+", " ", x, perl=TRUE); # collapse multiple spaces to a single space
  x = gsub("[--]+.*$", "", x, perl=TRUE); # destroy any comments
  return(x)
}
# PRETTYQUERY is the filename of your formatted query in quotes, eg "myquery.sql"
# DIRPATH is the path to that file, eg "~/Documents/queries"
ONELINEQ <- function(PRETTYQUERY,DIRPATH) { 
  A <- readLines(paste0(DIRPATH,"/",PRETTYQUERY)) # read in the query to a list of lines
  B <- lapply(A,LINECLEAN) # process each line
  C <- Filter(function(x) x != "",B) # remove blank and/or comment lines
  D <- paste(unlist(C),collapse=" ",sep=";") # paste lines together into one-line string, spaces between.
  return(D)
}

query2Creator<-function(dropQ,createQ,q1,domain,queryTableAlaises,outfilepath)
{ 
  newalaises<-vector(mode = "character", length = 0)
  
  
  for(i in 1:length(queryTableAlaises))
  {
    newalaises[i]<- gsub("_","",queryTableAlaises[i])
  }  
  
  q2<-q1
  #q2<-"o_e.,o_m.,r_e.,r_m.,"
  for(i in 1:length(queryTableAlaises))
  {
    q2<-gsub(paste0(queryTableAlaises[i],"._"),paste0("t.",newalaises[i]),q2)}
  
  oldfrom<-"FROM\n\tacs1115.acs_id_lookup g \n\tJOIN\n\traw_acs1115.b25093_e o_e \n\tON o_e.logrecno = g.logrecno \n\tJOIN\n\traw_acs1115.b25093_m o_m \n\tON o_m.logrecno = g.logrecno \n\tJOIN\n\traw_acs1115.b25072_e r_e \n\tON r_e.logrecno = g.logrecno \n\tJOIN\n\traw_acs1115.b25072_m r_m \n\tON r_m.logrecno = g.logrecno \n\tJOIN\n\tacs1115.acs_muni_geoid geo \n\tON geo.muni_id = g.muni_id \n\tWHERE\n\t(\n\tg.muni_id < 352 \n\tOR g.logrecno = 1 \n\tOR g.muni_id > 362\n\t)\n\tORDER BY\n\tg.muni_id;"
  
  newfrom<-paste0("\n FROM\n\tacs1115.aggre_muni_id_",domain," t \n\tJOIN\n\tacs1115.acs_muni_geoid geo \n\tON geo.muni_id = t.muni_id \n\tLEFT JOIN\n\tacs1115.acs_id_lookup g \n\tON g.muni_id = t.muni_id 			--Nothing will join from acd_id-lookup Just that goe_id and logrec number will get populated as null which is expected \n\tWHERE\n\t(\n\tt.muni_id >= 352 \n\tAND t.muni_id <= 362\n\t)\n\tOR \n\t(\n\tt.muni_id >= 377 \n\tAND t.muni_id <= 405\n\t)\n\tORDER BY\n\tt.muni_id;")
  
  q2<-gsub("g.muni_id","t.muni_id",q2)
  q2<-gsub("(?s)FROM.*",newfrom,q2,perl=TRUE,ignore.case=TRUE)
  #a<-strsplit(q2,"From")
  #a<-as.vector(unlist(a))
  #print(a)
  #a[2]<-newfrom
  #print(a[2])
  #q2<-paste(a[1],a[2],sep="\n")
  final=paste(dropQ,createQ,q1,q2,sep=";\n\n---------------------------------------------------------\n")
  final<-gsub("\'\' as acs_year","\'2011-15\' as acs_year ",final,perl=TRUE,ignore.case=TRUE)
  if (file.exists(paste0(outfilepath,"/",domain,"_final.sql"))) {
    file.remove(paste0(outfilepath,"/",domain,"_final.sql"))}
  outfilename=paste0(outfilepath,"/",domain,"_final.sql")
  file.create(outfilename)
  sink(outfilename,append=TRUE, split=FALSE)
  cat(final)
  sink()
}

inputtooutput<- function(filename,infilepath,outfilepath,maxcols,queryTables,queryTableAlaises,domain)
{
  sqlFileAutomation(domain,outfilepath,queryTables,queryTableAlaises,maxcols)
  z<-ONELINEQ(filename,infilepath)
  z = gsub("(?s)/\\*.*\\*/"," ",z, perl = TRUE)
  z = gsub(";",";\n\n",z, perl = TRUE)
  #sink("z.sql")
  #cat(z)
  #sink()
  f<-unlist(strsplit(z,split=";"))[1:3]
  query2Creator(f[1],f[2],f[3],domain,queryTableAlaises,outfilepath)
} 