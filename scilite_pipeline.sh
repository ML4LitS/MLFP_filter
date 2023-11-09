ROOT_DIR="/hps/nobackup/literature/text-mining/heapdump/"
# to set the base directory, so whatever heapdump is created will be in this directory.
cd $ROOT_DIR
pwd 

TIMESTAMP=$1
TODAY_DATE=$2
MONGO_LOADING=1
# remove old data from the given path to keep the directory clean
# change the log path and daily pipeline paths here.
# 7 is number of days that we delete and f is for files and d is for directory,.
sh /hps/software/users/literature/commons/remove_old_data.sh /hps/nobackup/literature/text-mining/mlfp_prod/logs 14 f
sh /hps/software/users/literature/commons/remove_old_data.sh /hps/nobackup/literature/text-mining/mlfp_prod/daily_pipeline_api 14 d

MONGO_DB_URL="ALL_ROUTERS"
COLLECTION_NAME="annotationsApi"

PIPELINE_PATH_ABSTRACT="/hps/software/users/literature/textmining/mlfp_prod_pipeline/abstract/pipelineUnifiedAbstract_expMethods.sh"
NUM_FILE_X_JOB_ABSTRACT=2

PIPELINE_PATH_FULLTEXT="/hps/software/users/literature/textmining/mlfp_prod_pipeline/fulltext/pipelineUnified_repo.sh"
NUM_FILE_X_JOB_FULLTEXT=2

#fulltext pipeline
sh /hps/software/users/literature/textmining/mlfp_prod_pipeline/fulltext/scilite_fulltext_pipeline.sh $TIMESTAMP $TODAY_DATE $PIPELINE_PATH_FULLTEXT $NUM_FILE_X_JOB_FULLTEXT


echo "Finished fulltext pipeline, about to start abstract pipeline"

#abstract pipeline
sh /hps/software/users/literature/textmining/mlfp_prod_pipeline/abstract/scilite_abstract_pipeline.sh $TIMESTAMP $TODAY_DATE $PIPELINE_PATH_ABSTRACT $NUM_FILE_X_JOB_ABSTRACT


#echo "about to start mongo loading"

#mongo loading
#if [ $MONGO_LOADING -gt 0 ]
#        then
#
#        MONGO_PIPELINE_PATH="/hps/software/users/literature/textmining/mongo/mongo_pipeline.sh"
#
#        sh $MONGO_PIPELINE_PATH send_minio_abstract $TODAY_DATE $TIMESTAMP
#
#        sh $MONGO_PIPELINE_PATH send_minio_fulltext $TODAY_DATE $TIMESTAMP
#
#        sh $MONGO_PIPELINE_PATH backup $MONGO_DB_URL $COLLECTION_NAME $TODAY_DATE
#
#fi
