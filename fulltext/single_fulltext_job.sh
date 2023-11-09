source /hps/software/users/literature/textmining/mlfp_prod_pipeline/common_functions.sh
source /hps/software/users/literature/commons/scripts/SetJava8ClassPath.sh

initiateVariables

TIMESTAMP=$1                                                                
TODAY_DATE=$2
INDEX_JOB=$3
PIPELINE_PATH=$4

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

getScilitePipelineValue "source_dir_job" "fulltext" "$TODAY_DATE" $INDEX_JOB
SRC_DIR=$SCILITE_PIPELINE_VALUE

getScilitePipelineValue "annotation_dir_job" "fulltext" "$TODAY_DATE" $INDEX_JOB
ANN_DIR=$SCILITE_PIPELINE_VALUE

getScilitePipelineValue "summary_file_rdf" "fulltext" "$TODAY_DATE"
SUMMARY_FILE_ANNOTATED_RDF=$SCILITE_PIPELINE_VALUE

getScilitePipelineValue "summary_file_api" "fulltext" "$TODAY_DATE"
SUMMARY_FILE_ANNOTATED_JSON_API=$SCILITE_PIPELINE_VALUE

getScilitePipelineValue "summary_file_highlight" "fulltext" "$TODAY_DATE"
SUMMARY_FILE_ANNOTATED_JSON_HIGHLIGHT=$SCILITE_PIPELINE_VALUE

getScilitePipelineValue "flag_job_finished" "fulltext" "$TODAY_DATE" $INDEX_JOB
FLAG_JOB_FINISHED=$SCILITE_PIPELINE_VALUE

echo "INDEX JOB FULLTEXT $INDEX_JOB Pipeline path $PIPELINE_PATH FLAG_JOB_FINISHED $FLAG_JOB_FINISHED SUMMARY_FILE_ANNOTATED_JSON_HIGHLIGHT $SUMMARY_FILE_ANNOTATED_JSON_HIGHLIGHT SUMMARY_FILE_ANNOTATED_JSON_API $SUMMARY_FILE_ANNOTATED_JSON_API SUMMARY_FILE_ANNOTATED_RDF $SUMMARY_FILE_ANNOTATED_RDF  LOG $LOG_FILE ERR $ERR_FILE JSON_DIR_API $JSON_DIR_API JSON HIGHLIGHT $JSON_DIR_HIGHLIGHT RDF DIR $RDF_DIR SRC DIR $SRC_DIR ANN DIR $ANN_DIR" >> $LOG_FILE
     
EXTENSION="xml";
#annotate article
for SRC_FILE in $SRC_DIR/patch-$TIMESTAMP-*.$EXTENSION.gz 
do
	FILE_NAME=${SRC_FILE##*/}
       	echo "annotating article   $FILE_NAME" >> $LOG_FILE
       	zcat $SRC_DIR/$FILE_NAME | sh $PIPELINE_PATH $ERR_FILE annotation $EXTENSION | gzip > $ANN_DIR/$FILE_NAME
done
  

LENGHT_EXTENSION=${#EXTENSION}
LENGHT_EXTENSION=`expr $LENGHT_EXTENSION + 4`


#generate rdf/json
for ANN_FILE in $ANN_DIR/patch-$TIMESTAMP-*.$EXTENSION.gz
do
	FILE_NAME=${ANN_FILE##*/}
       	LENGTH_FILE_NAME=${#FILE_NAME}
       	LENGTH_FILE_NAME=`expr $LENGTH_FILE_NAME - $LENGHT_EXTENSION` 
      
       	FILE_ORIGINAL_NAME=${FILE_NAME:0:$LENGTH_FILE_NAME}
       JSON_API_FILE="$FILE_ORIGINAL_NAME.api.json"
       zcat $ANN_DIR/$FILE_NAME | sh $PIPELINE_PATH $ERR_FILE 4jsonapi $EXTENSION $SUMMARY_FILE_ANNOTATED_JSON_API > $JSON_DIR_API/$JSON_API_FILE 
     
done

touch $FLAG_JOB_FINISHED

exit 0

