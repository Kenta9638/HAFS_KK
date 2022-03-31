#!/bin/sh

module load rocoto

wfname=hafs-TEST_20211021_040mem_LoPF_MIXwGDAS-00L-2020081100
lfname=log/test_log_TEST_20211021_040mem_LoPF_MIXwGDAS.log

rocotofile=$wfname.xml
rocotofile2=$wfname.db

#sdate=202008110006   #For rewinding specific cycle; Note the two extra zeroes
sdate=202008130600   #For rewinding specific cycle; Note the two extra zeroes
edate=202008130600   #For rewinding specific cycle; Note the two extra zeroes
#edate=202008121800   #For rewinding specific cycle; Note the two extra zeroes
#sdate=202008180000   #For rewinding specific cycle; Note the two extra zeroes
#edate=202008271800   #For rewinding specific cycle; Note the two extra zeroes

SDATE=`echo $sdate | cut -c 1-10`
EDATE=`echo $edate | cut -c 1-10`

#VARS[0]="enkf_update"
#VARS[0]="long"
#VARS[1]="enkf_hx_mean"
#VARS[0]="forecast_ens"
VARS[0]="enkf_hx_ens"
#VARS[2]="atm_post_ens"
#VARS[3]="LOST"
#VARS[5]="SUBMITTING"
#VARS[6]="QUEUED"
#VARS[7]="RUNNING"
#VARS[8]="SUCCEEDED"

ARRAY_line=()
NUM_VARS=${#VARS[@]}

CDATE=$SDATE
while [[ $CDATE -le $EDATE ]]; do

  tmp_date=${CDATE}00

  COUNTER=0
  while [ $COUNTER -ne $NUM_VARS ]; do
    tmp_VAR=${VARS[$COUNTER]}
    
    while read line; do
      if [[ $line =~ $tmp_VAR ]]; then
      if [[ $line =~ $tmp_date ]]; then
        tmp_line=`echo $line`
        tmp_task=`echo $tmp_line | cut -d " " -f2`
#        tmp_task=rst_gdas_ens
#        tmp_task=enkf_update
        echo $tmp_date
        echo $tmp_task
        echo $tmp_VAR
        echo "rocotorewind -w $rocotofile -d $rocotofile2 -c $tmp_date -t $tmp_task"
        rocotorewind -w $rocotofile -d $rocotofile2 -c $tmp_date -t $tmp_task
        echo "----------------------"
      fi
      fi

    done < $lfname

    COUNTER=`expr $COUNTER + 1`
  done

  YY=`echo ${CDATE}|cut -c 1-4` ; MM=`echo ${CDATE}|cut -c 5-6`
  DD=`echo ${CDATE}|cut -c 7-8` ; HR=`echo ${CDATE}|cut -c 9-10`
  NDATE=`date -d "${YY}${MM}${DD} ${HR} 6 hour" +%Y%m%d%H`
  CDATE=${NDATE}
done


exit

