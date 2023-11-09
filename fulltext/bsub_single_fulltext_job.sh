source ~/.bashrc

LSF_EMAIL="email"

TIMESTAMP=$1
TODAY_DATE=$2
INDEX_JOB=$3
PIPELINE_PATH=$4

bsub -J "MLFP_FULLTEXT_GENERATION $TODAY_DATE $INDEX_JOB" -M 55024 -R "rusage[mem=55024]" -N -q datamover -u $LSF_EMAIL -oo "/hps/nobackup/literature/text-mining/mlfp_prod/logs/rdf_mlfp_`date +\"%Y%m%d%H%M%S\"`.log" "/hps/software/users/literature/textmining/mlfp_prod_pipeline/fulltext/single_fulltext_job.sh $TIMESTAMP $TODAY_DATE $INDEX_JOB $PIPELINE_PATH"

