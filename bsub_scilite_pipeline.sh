source ~/.bashrc

LSF_EMAIL="<YOUREMAIL>"

TIMESTAMP="$(date --date="1 day ago" +'%d-%m-%Y')"
#TIMESTAMP="$(date --date="2 days ago" +'%d-%m-%Y')"
#TIMESTAMP="19-11-2022"
#TIMESTAMP="total"


now="$(date +'%d_%m_%Y')"
TODAY_DATE=`printf "%s" "$now"`
#TODAY_DATE="01_08_2000"

bsub -J "MLFP_Prod $TIMESTAMP" -M 5024 -R "rusage[mem=5024]" -B -N -q production -u $LSF_EMAIL -oo "/hps/nobackup/literature/text-mining/mlfp_prod/logs/mlfp_prod_log_`date +\"%Y%m%d%H%M%S\"`.log" "/hps/software/users/literature/textmining/mlfp_prod_pipeline/scilite_pipeline.sh $TIMESTAMP $TODAY_DATE"

