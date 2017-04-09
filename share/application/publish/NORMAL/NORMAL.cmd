#!/bin/sh
#

#BatchConstants.JOB_SUBMISSION_CUSTOMIZE_CMD = customize_cmd
#BatchConstants.JOB_SUBMISSION_GENERIC = generic
#BatchConstants.CLUSTER_NAME = cluster_name

. ${SHARE_DIR}/application/basic

JSS_OPT=""
ADVANCED_OPT=""
CUSTOMIZE_OPT=""

#when user implement the method of using multiple file in job submission,
#comment this default control.
isMultiFile=`echo "$INPUT_FILE" | awk '{ if(index($0,";") == 0) {print "N";} else {print "Y";}}'`
if [ "$isMultiFile" = "Y" ] ; then
	echo -n "Multiple input files have been uploaded. We support single file case by default," 
	echo "you need handle multiple file case in shell script by yourself." 
	exit 1
fi
isMultiFile=`echo "$ERROR_FILE" | awk '{ if(index($0,";") == 0) {print "N";} else {print "Y";}}'`
if [ "$isMultiFile" = "Y" ] ; then
	echo -n "Multiple error files have been uploaded. We support single file case by default," 
	echo "you need handle multiple file case in shell script by yourself." 
	exit 1
fi
isMultiFile=`echo "$OUTPUT_FILE" | awk '{ if(index($0,";") == 0) {print "N";} else {print "Y";}}'`
if [ "$isMultiFile" = "Y" ] ; then
	echo -n "Multiple output files have been uploaded. We support single file case by default," 
	echo "you need handle multiple file case in shell script by yourself." 
	exit 1
fi

#------------------------basic option----------------------------------
if [ "x$COMMANDTORUN" = "x" ] ; then
	echo "Job command was not specified " 
	exit 1
fi

JOB_COMMAND=`echo "$COMMANDTORUN" | awk -F":" '{ print $1}'`
if [ "x$JOB_COMMAND" = "x" ] ; then
	echo "Job command was not specified " 
	exit 1
fi

JOB_PATH=`echo "$COMMANDTORUN" | awk -F":" '{ gsub("\"",""); print $2}'`
if [ "x$JOB_PATH" != "x" ] ; then
	PATH="$JOB_PATH":$PATH
	export PATH
	chmod -R a+x "$JOB_PATH" 
fi

if [ "x$JOB_NAME" != "x" ]; then
   JSS_OPT="-J \"${JOB_NAME}\""
fi

if [ "$CONSOLE_SUPPORT" = "Yes" ]; then      
   export VNC_SID=`${SHARE_DIR}/vnc/startvnc.sh ${USER} ${VNC_WIDTH} ${VNC_HEIGHT}`    
   export DISPLAY="${VNC_SERVER}:${VNC_SID}.0"  
   
fi  

#------------------------data options-----------------------------

if [ "x${INPUT_FILE}" != "x" ]; then
	INPUT_FILE=`formatFilePath "${INPUT_FILE}"`
	#INPUT_FILE="\"${INPUT_FILE}\""
	JSS_OPT="$JSS_OPT -i $INPUT_FILE"
fi

## create error file and output file

ERROR_FILE="$OUTPUT_FILE_LOCATION/errfile.txt"
OUTPUT_FILE="$OUTPUT_FILE_LOCATION/outfile.txt"
touch $ERROR_FILE
touch $OUTPUT_FILE

if [ "x$ERROR_FILE" != "x" ]; then
	ERROR_FILE=`formatFilePath "${ERROR_FILE}"`
	JSS_OPT="$JSS_OPT -e $ERROR_FILE"
fi

if [ "x$OUTPUT_FILE" != "x" ]; then
#	OUTPUT_FILE=`formatFilePath "${OUTPUT_FILE}"`
	JSS_OPT="$JSS_OPT -o $OUTPUT_FILE"
fi

###-----------------------Requirements------------------------------

if [ "x$NCPU" != "x" ]; then
    ADVANCED_OPT="$ADVANCED_OPT -n $NCPU"
fi

if [ "x$PROJECT" != "x" ]; then
    ADVANCED_OPT="$ADVANCED_OPT -P $PROJECT" 
fi

###-----------------------Additional Job Options--------------------

if [ "x$QUEUE" != "x" ]; then
    ADVANCED_OPT="$ADVANCED_OPT -q $QUEUE"
fi

###--------------------------limits options-------------------------

CWD_OPT="-cwd \"$OUTPUT_FILE_LOCATION\""

/bin/sh -c "bsub ${CWD_OPT} ${JSS_OPT} ${ADVANCED_OPT} ${JOB_COMMAND}"

if [ "$CONSOLE_SUPPORT" = "Yes" -a "$JOB_COMMAND" != "glxgears" ]; then
	mkdir -p ${OUTPUT_FILE_LOCATION}/.action
    ACTION_SCRIPT="${OUTPUT_FILE_LOCATION}/.action/monitor.sh"
    echo '#!/bin/bash' > ${ACTION_SCRIPT}
    echo "export VNC_SID=`${SHARE_DIR}/vnc/startvnc.sh ${USER} ${VNC_WIDTH} ${VNC_HEIGHT}`" >> ${ACTION_SCRIPT}
    echo "export DISPLAY=\"${VNC_SERVER}:${VNC_SID}.0\"" >> ${ACTION_SCRIPT}
    echo "glxgears &" >> ${ACTION_SCRIPT}
fi
