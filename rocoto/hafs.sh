#!/bin/sh -x

set -e

echo `date`

# Set to true if starting from scratch
#expt_init=true
expt_init=false

# Paths for MSU Orion
HOMEhafs=/work/noaa/aoml-hafsda/kurosawa/WORK/HAFS_RUN/TEST_20211021/
dev="-s sites/orion.ent -f"
PYTHON3=/apps/intel-2020/intel-2020/intelpython3/bin/python3

cd ${HOMEhafs}/rocoto

EXPT=$(basename ${HOMEhafs})

scrubopt="config.scrub_work=no config.scrub_com=no"


#===============================================================================
# Here are some simple examples, more examples can be seen in cronjob_hafs_rt.sh

# Run all cycles of a storm
#${PYTHON3} ./run_hafs.py ${dev} 2019 05L HISTORY config.EXPT=${EXPT}# Dorian

# Run specified cycles of a storm
#${PYTHON3} ./run_hafs.py ${dev} 2018083018-2018083100 06L HISTORY \
#   config.EXPT=${EXPT} config.SUBEXPT=${EXPT}_try1 # Florence

# Cycle
yyyymmddhh_str=2020081100
yyyymmddhh_end=2020081800
#yyyymmddhh_str=2020081800
#yyyymmddhh_end=2020090300

times=$yyyymmddhh_str-$yyyymmddhh_end

SDATE=$yyyymmddhh_str
EDATE=$yyyymmddhh_end

MEM1=40
MEM2=`printf "%0*d"  3 $MEM1`
expt_num=05

# Specify experiment
case "$expt_num" in
# "00") expt=${EXPT}_TEST0_${MEM2}mem_${yyyymmddhh_str}-${yyyymmddhh_end} ;;   # 00
# "01") expt=${EXPT}_TEST1_${MEM2}mem_${yyyymmddhh_str}-${yyyymmddhh_end} ;;   # 01
 "01") expt=${EXPT}_${MEM2}mem_EnKF ;;   # 01
 "02") expt=${EXPT}_${MEM2}mem_EnKF_MIXwGDAS ;;   # 02
 "03") expt=${EXPT}_${MEM2}mem_LoPF_MIXwGDAS_Neff08 ;;   # 03
 "04") expt=${EXPT}_${MEM2}mem_LoPF_MIXwGDAS_Neff08_Hyb05;;   # 04
 "05") expt=${EXPT}_${MEM2}mem_EnKF_RTPS095 ;;   # 05
 "06") expt=${EXPT}_${MEM2}mem_EnKF_MIXwGDAS_debug ;;   # 06
# "04") expt=${EXPT}_${MEM2}mem_EnVAR_rgnl_ens ;;   # 04
# "05") expt=${EXPT}_${MEM2}mem_EnVAR_gdas_ens ;;   # 05
# "99") expt=${EXPT}_TEST9_${MEM2}mem_${yyyymmddhh_str}-${yyyymmddhh_end} ;;   # 99
esac

# Current workflow name
wfname=hafs-${expt}-00L-${yyyymmddhh_str}
#wfname=hafs-${expt}-00L
#wfname=log-${expt}

# Initiate workflow
if $expt_init; then

  rm -f ${wfname}.db ${wfname}_lock.db ${wfname}.xml

fi 

done_flag=0
exit_flag=0
rm -f done_file

while [[ $done_flag -eq 0 ]]; do

  if [[ $exit_flag -eq 1 ]]; then
    exit
  fi

  case "$expt_num" in

   "01" ) # EnKF
     ${PYTHON3} ./run_hafs.py -t ${dev} ${times} 00L HISTORY \
     config.EXPT=${EXPT} config.SUBEXPT=${expt} \
     config.run_gsi_vr=no config.run_gsi_vr_fgat=no config.run_gsi_vr_ens=no \
     config.run_gsi=yes config.run_fgat=yes config.run_envar=yes \
     config.run_ensda=yes config.ENS_SIZE=$MEM1 config.run_enkf=yes \
     config.online_satbias=no \
     config.run_recenter=no \
     config.lpf_opt=no \
     config.da_opt=yes \
     gsi.use_bufr_nr=yes \
     config.warm_start_opt=5 \
     config.NHRS=102 \
     config.NHRS_ENS=6 \
     config.run_long_forecast_ens=yes \
     config.NHRS_ENS_LONG=102 \
     config.RTPS_PARA=0.85 \
     config.run_emcgraphics=yes ${scrubopt} \
     ../parm/hafsv0p2a_da_AL_6km.conf \
     ../parm/hafs_hycom.conf
     ;;

   "02" ) # EnKF with mix ens
     ${PYTHON3} ./run_hafs.py -t ${dev} ${times} 00L HISTORY \
     config.EXPT=${EXPT} config.SUBEXPT=${expt} \
     config.run_gsi_vr=no config.run_gsi_vr_fgat=no config.run_gsi_vr_ens=no \
     config.run_gsi=yes config.run_fgat=yes config.run_envar=yes \
     config.run_ensda=yes config.ENS_SIZE=$MEM1 config.run_enkf=yes \
     config.online_satbias=no \
     config.run_recenter=no \
     config.lpf_opt=no \
     config.da_opt=yes \
     gsi.use_bufr_nr=yes \
     config.warm_start_opt=5 \
     config.NHRS=102 \
     config.NHRS_ENS=6 \
     config.run_long_forecast_ens=yes \
     config.NHRS_ENS_LONG=102 \
     config.run_mix_ens_da=yes \
     config.SUM_MIX_ENS_SIZE=120 \
     config.GDAS_MIX_ENS_SIZE=80 \
     config.RTPS_PARA=0.85 \
     config.run_emcgraphics=yes ${scrubopt} \
     ../parm/hafsv0p2a_da_AL_6km.conf \
     ../parm/hafs_hycom.conf
     ;;

   "03" ) # LoPF with mix ens
     ${PYTHON3} ./run_hafs.py -t ${dev} ${times} 00L HISTORY \
     config.EXPT=${EXPT} config.SUBEXPT=${expt} \
     config.run_gsi_vr=no config.run_gsi_vr_fgat=no config.run_gsi_vr_ens=no \
     config.run_gsi=yes config.run_fgat=yes config.run_envar=yes \
     config.run_ensda=yes config.ENS_SIZE=$MEM1 config.run_enkf=yes \
     config.online_satbias=no \
     config.run_recenter=no \
     config.lpf_opt=yes \
     config.da_opt=yes \
     gsi.use_bufr_nr=yes \
     config.warm_start_opt=5 \
     config.NHRS=102 \
     config.NHRS_ENS=6 \
     config.run_long_forecast_ens=yes \
     config.NHRS_ENS_LONG=102 \
     config.run_mix_ens_da=yes \
     config.SUM_MIX_ENS_SIZE=120 \
     config.GDAS_MIX_ENS_SIZE=80 \
     config.RTPS_PARA=0.85 \
     config.MIN_RES=0.00 \
     config.run_emcgraphics=yes ${scrubopt} \
     ../parm/hafsv0p2a_da_AL_6km.conf \
     ../parm/hafs_hycom.conf
     ;;

   "04" ) # PF-EnKF Hybrid
     ${PYTHON3} ./run_hafs.py -t ${dev} ${times} 00L HISTORY \
     config.EXPT=${EXPT} config.SUBEXPT=${expt} \
     config.run_gsi_vr=no config.run_gsi_vr_fgat=no config.run_gsi_vr_ens=no \
     config.run_gsi=yes config.run_fgat=yes config.run_envar=yes \
     config.run_ensda=yes config.ENS_SIZE=$MEM1 config.run_enkf=yes \
     config.online_satbias=no \
     config.run_recenter=no \
     config.lpf_opt=yes \
     config.da_opt=yes \
     gsi.use_bufr_nr=yes \
     config.warm_start_opt=5 \
     config.NHRS=102 \
     config.NHRS_ENS=6 \
     config.run_long_forecast_ens=yes \
     config.NHRS_ENS_LONG=102 \
     config.run_mix_ens_da=yes \
     config.SUM_MIX_ENS_SIZE=120 \
     config.GDAS_MIX_ENS_SIZE=80 \
     config.RTPS_PARA=0.85 \
     config.MIN_RES=0.50 \
     config.run_emcgraphics=yes ${scrubopt} \
     ../parm/hafsv0p2a_da_AL_6km.conf \
     ../parm/hafs_hycom.conf
     ;;

   "05" ) # EnKF RTPS:0.95
     ${PYTHON3} ./run_hafs.py -t ${dev} ${times} 00L HISTORY \
     config.EXPT=${EXPT} config.SUBEXPT=${expt} \
     config.run_gsi_vr=no config.run_gsi_vr_fgat=no config.run_gsi_vr_ens=no \
     config.run_gsi=yes config.run_fgat=yes config.run_envar=yes \
     config.run_ensda=yes config.ENS_SIZE=$MEM1 config.run_enkf=yes \
     config.online_satbias=no \
     config.run_recenter=no \
     config.lpf_opt=no \
     config.da_opt=yes \
     gsi.use_bufr_nr=yes \
     config.warm_start_opt=5 \
     config.NHRS=102 \
     config.NHRS_ENS=6 \
     config.run_long_forecast_ens=no \
     config.NHRS_ENS_LONG=102 \
     config.run_mix_ens_da=no \
     config.RTPS_PARA=0.95 \
     config.run_emcgraphics=no ${scrubopt} \
     ../parm/hafsv0p2a_da_AL_6km.conf \
     ../parm/hafs_hycom.conf
     ;;


   esac


   sleep 60

   # rocoto_check
 #  rocotostat -w ${wfname}.xml -d ${wfname}.db -c all > log/test_log_${expt}.log
   rocotostat -w ${wfname}.xml -d ${wfname}.db -c all > log/test_log_${expt}_${yyyymmddhh_str}.log


   # Check to see if completion task finished
   done_flag=`rocotostat -w ${wfname}.xml -d ${wfname}.db -c "${yyyymmddhh_end}00" | grep donefile | grep SUCCEEDED | wc -l`

   # Check DEAD 
   CDATE=$SDATE
   while [[ $CDATE -le $EDATE ]]; do
    done_flag=`rocotostat -w ${wfname}.xml -d ${wfname}.db -c "${CDATE}00" | grep DEAD | wc -l`
    if [[ $done_flag -gt 0 ]]; then
      tmp1=`rocotostat -w ${wfname}.xml -d ${wfname}.db -c "${CDATE}00" | grep DEAD |  cut -d' ' -f9`
    #  echo 
      exit_flag=1
      exit
    fi
    YY=`echo ${CDATE}|cut -c 1-4` ; MM=`echo ${CDATE}|cut -c 5-6`
    DD=`echo ${CDATE}|cut -c 7-8` ; HR=`echo ${CDATE}|cut -c 9-10`
    NDATE=`date -d "${YY}${MM}${DD} ${HR} 6 hour" +%Y%m%d%H`
    CDATE=$NDATE
   done

   # Kill switch
   if [[ -e done_file ]]; then
     exit
   fi
 


done


#===============================================================================

echo `date`
