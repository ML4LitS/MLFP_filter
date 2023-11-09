source /hps/software/users/literature/textmining/mlfp_prod_pipeline/common_functions.sh
source /hps/software/users/literature/commons/scripts/SetJava11ClassPath.sh

initiateVariables

TIMESTAMP=$1
TODAY_DATE=$2
PIPELINE_PATH=$3
NUM_FILES_PER_JOB=$4

USERNAME_DB_CDB="xxx"
PASSWORD_DB_CDB="xxx"
URL_DB_CDB="xxx"
SCHEMA_DB_CDB="xxx"
MAX_DOCS=1000
DOMAIN_API="xxx"
getScilitePipelineValue "log_dir" "fulltext" "$TODAY_DATE"
LOG_DIR=$SCILITE_PIPELINE_VALUE

getScilitePipelineValue "log_file" "fulltext" "$TODAY_DATE"
LOG_FILE=$SCILITE_PIPELINE_VALUE

getScilitePipelineValue "error_file" "fulltext" "$TODAY_DATE"
ERR_FILE=$SCILITE_PIPELINE_VALUE

getScilitePipelineValue "json_api_dir" "fulltext" "$TODAY_DATE"
JSON_DIR_API=$SCILITE_PIPELINE_VALUE

getScilitePipelineValue "4summary_dir" "fulltext" "$TODAY_DATE"
FOR_SUMMARY_DIR=$SCILITE_PIPELINE_VALUE

getScilitePipelineValue "json_highlight_dir" "fulltext" "$TODAY_DATE"
JSON_DIR_HIGHLIGHT=$SCILITE_PIPELINE_VALUE

getScilitePipelineValue "rdf_dir" "fulltext" "$TODAY_DATE"
RDF_DIR=$SCILITE_PIPELINE_VALUE

getScilitePipelineValue "source_dir" "fulltext" "$TODAY_DATE"
SRC_DIR=$SCILITE_PIPELINE_VALUE

getScilitePipelineValue "summary_dir" "fulltext" "$TODAY_DATE"
SUMMARY_DIR=$SCILITE_PIPELINE_VALUE

getScilitePipelineValue "rdf_flag_generated" "fulltext" "$TODAY_DATE"
RDF_FLAG_GENERATED=$SCILITE_PIPELINE_VALUE

createDirectory "$LOG_DIR"
createDirectory "$RDF_DIR"
createDirectory "$SUMMARY_DIR"
createDirectory "$JSON_DIR_API"
createDirectory "$JSON_DIR_HIGHLIGHT"
createDirectory "$FOR_SUMMARY_DIR"
createDirectory "$SRC_DIR"

echo "MAIN FULLTEXT PIPELINE LOG_DIR $LOG_DIR SUMMARY_DIR $SUMMARY_DIR LOG $LOG_FILE ERR $ERR_FILE JSON_DIR_API $JSON_DIR_API JSON HIGHLIGHT $JSON_DIR_HIGHLIGHT RDF DIR $RDF_DIR SRC DIR $SRC_DIR RDF_FLAG_GENERATED $RDF_FLAG_GENERATED DOMAIN_API $DOMAIN_API" >> $LOG_FILE

echo "Timestamp $TIMESTAMP" >> $LOG_FILE
echo "Today $TODAY_DATE" >> $LOG_FILE
echo "Pipeline fulltext $PIPELINE_PATH" >> $LOG_FILE
echo "NUM_FILES_PER_JOB $NUM_FILES_PER_JOB" >> $LOG_FILE

EXTENSION="xml"
#fetching data into the source folder 
sh $PIPELINE_PATH $ERR_FILE fetch $EXTENSION $SRC_DIR $TIMESTAMP $MAX_DOCS $SUMMARY_DIR $LOG_FILE $USERNAME_DB_CDB $PASSWORD_DB_CDB $URL_DB_CDB $SCHEMA_DB_CDB $DOMAIN_API

#checking number of files
NUM_SRC_FILES=`ls $SRC_DIR | wc -l`
echo "number of source files $NUM_SRC_FILES"
   
#annotate article
   
if [ $NUM_SRC_FILES -gt 0 ] 
then

	NUM_JOBS=0; 
        for (( index=0; index<$NUM_SRC_FILES; index++ ))
        do
          #raggiunto num file per jobs
           echo "analyzing file $index "
           
           

           if [ `expr $index % $NUM_FILES_PER_JOB` -eq 0 ]
           then
                NUM_JOBS=`expr $NUM_JOBS + 1`

                getScilitePipelineValue "source_dir_job" "fulltext" "$TODAY_DATE" $NUM_JOBS
                SRC_JOB_DIR=$SCILITE_PIPELINE_VALUE  
                createDirectory "$SRC_JOB_DIR"

                getScilitePipelineValue "annotation_dir_job" "fulltext" "$TODAY_DATE" $NUM_JOBS
                ANN_JOB_DIR=$SCILITE_PIPELINE_VALUE
                createDirectory "$ANN_JOB_DIR"                   
                
                echo "created directory job $SRC_JOB_DIR and $ANN_JOB_DIR" #> $LOG_FILE
                
               #creating directory and increment num jobs
           fi

           cp $SRC_DIR/patch-$TIMESTAMP-$index.$EXTENSION.gz $SRC_JOB_DIR/
           
           echo "coping file $SRC_DIR/patch-$TIMESTAMP-$index.$EXTENSION.gz to $SRC_JOB_DIR"
     
        done

        for (( index=1; index<=$NUM_JOBS; index++ ))
        do
            sh /hps/software/users/literature/textmining/mlfp_prod_pipeline/fulltext/bsub_single_fulltext_job.sh $TIMESTAMP $TODAY_DATE $index $PIPELINE_PATH
           echo "submitting job bsub_single_fulltext_job.sh  $TIMESTAMP $TODAY_DATE $index $PIPELINE_PATH" #> $LOG_FILE
        done

:
        #waiting for all the jobs to finish
        for (( index=1; index<=$NUM_JOBS; index++ ))
        do
                getScilitePipelineValue "flag_job_finished" "fulltext" "$TODAY_DATE" $index
                TASK_FINISHED_FLAG=$SCILITE_PIPELINE_VALUE
              	attempts=0
		while true; do
        		if [ $attempts -gt 5000 ]
        		then
                		echo "Waiting for more then 500o minutes for the generation RDF/JSON file job $index to finish" #> $LOG_FILE
                		echo "RFD/JSON files have not been generated after 5000 minutes" | Mail -s "Scilite fulltext pipeline FAIL" $MAIL_RECIPIENTS
                		exit 1
        		fi

        		if [ -f $TASK_FINISHED_FLAG ]
        		then
                		echo "job $index finished"  #$LOG_FILE
                		break
        		fi

        		echo "making another attempt to read the file $TASK_FINISHED_FLAG"

        		attempts=`expr $attempts + 1`
        		sleep 60
		done
        done        

      
fi

if [ $NUM_SRC_FILES -gt 0 ]
   then
   touch $RDF_FLAG_GENERATED
   echo "RDF/JSON SCILITE FULLTEXT files have been generated at $RDF_DIR, $JSON_DIR_HIGHLIGHT,  $JSON_DIR_API" | Mail -s "SCILITE FULLTEXT ANNOTATION FILE GENERATED $TODAY_DATE" $MAIL_RECIPIENTS
else
   echo " NO RDF/JSON files have been generated from SCILITE FULLTEXT pipeline" | Mail -s "SCILITE FULLTEXT ANNOTATION FILE GENERATED $TODAY_DATE" $MAIL_RECIPIENTS
fi

exit 0

