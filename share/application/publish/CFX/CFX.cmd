#!/bin/sh
#

if [  "x$VERSION" = "x12.1" ]; then   
CFX_CMD="/app/ansys_inc/v121/CFX/bin/cfx5solve"
CFX_PATH="/app/ansys_inc/v121/CFX/bin"
fi
if [  "x$VERSION" = "x13.0" ]; then   
CFX_CMD="/app/ansys_inc13/v130/CFX/bin/cfx5solve"
CFX_PATH="/app/ansys_inc13/v130/CFX/bin"
fi
if [  "x$VERSION" = "x14.0" ]; then   
CFX_CMD="/app/ansys_inc14/v140/CFX/bin/cfx5solve"
CFX_PATH="/app/ansys_inc14/v140/CFX/bin"
fi

export  MPI_REMSH=ssh

PATH=${CFX_PATH}:$PATH

RELEASE="11.0"

. ${SHARE_DIR}/application/basic

export WORKDIR="$OUTPUT_FILE_LOCATION"
export LSF_FROM_WEB="Y"

if [ "x$PROJECT" = "x" ]; then
    PROJECT="project"
fi

if [ "x$QUEUE" != "x" ]; then
        SUB_QUEUE_OPT="-q $QUEUE"
else
        SUB_QUEUE_OPT=""
fi

if [ "x$NCPU" != "x" ]; then
        NCPU_OPT="-n $NCPU"
else
        NCPU_OPT=""
fi

if [ "x$DEF_INPUT_FILE" = "x" ]; then
    echo "You must specify a definition input (.def) file." 1>&2
    exit 1
fi

if [ "x$JOB_NAME" = "x" ]; then
        JSS_DEF=`basename ${DEF_INPUT_FILE}|sed 's/"$//'`
        TAG="S"
        if [ "$DOUBLE_SUPPORT" = "Yes" ]; then
                TAG="${TAG}D"
        fi
        if [ "x$PRIORITY" = "xhigh" ]; then
                TAG="${TAG}H"
        fi
        JOB_NAME="cfx${RELEASE}_${TAG}_${NCPU}_${JSS_DEF}"
fi
JSS_DEF=`basename ${DEF_INPUT_FILE}|sed 's/"$//'`

if [ "x$ITE_NUM" != "x" ]; then
    JOB_NAME="${JOB_NAME}_${ITE_NUM}"
fi

CFX_OPT=" -def $JSS_DEF "
if [ ! "x$RES_INPUT_FILE" = "x" ]; then
        JSS_RES=`basename ${RES_INPUT_FILE}|sed 's/"$//'`
        CFX_OPT="$CFX_OPT -ini $JSS_RES "
fi
if [ ! "x$DOUBLE_SUPPORT" = "xYes" ]; then
        CFX_OPT="$CFX_OPT  -double "
fi
if [ ! "x$INTERPOLATE" = "xYes" ]; then
        CFX_OPT="$CFX_OPT -interpolate-iv "
fi

if [ ! "x$INI_FILE" = "x" ]; then
        JSS_RES=`basename ${INI_FILE}|sed 's/"$//'`
        CFX_OPT="$CFX_OPT -ini-file  $JSS_RES "
fi



CFX_OPT="$CFX_OPT -sizepart $PAR_MEM_FACTOR -S $SOL_MEM_FACTOR "
#LSF_RESREQ="select[type==any] rusage[CFX_SOLVER=1,CFX_PAR=${NCPU}]"
if [ "x$LSF_RESREQ" != "x" ]; then
        LSF_RESREQ="-R \"$LSF_RESREQ\""
fi

export CONSOLE_SUPPORT="Yes"
export VNC_SID=`${SHARE_DIR}/vnc/startvnc.sh ${USER} ${VNC_WIDTH} ${VNC_HEIGHT}`    
GRAPHIC_OPT=""  
export DISPLAY="${VNC_SERVER}:${VNC_SID}.0"

if [ "x$INTERACTIVE_SUPPORT" = "xYes" ]; then
	/bin/sh -c "bsub -app cfx  -P ${PROJECT} -B -N -J ${JOB_NAME} ${CWD_OPT} ${SUB_QUEUE_OPT} ${RUNHOST_OPT} ${NCPU_OPT} ${LSF_RESREQ} -o \"${OUTPUT_FILE_LOCATION}/output.%J\" ${EXTRA_PARAMS} \"${CFX_CMD} -interactive  -P acfx_solver $CFX_OPT  >> cfx.log  \""
else
	CFX_OPT="$CFX_OPT -start-method \"$RUN_MODE\"  "
	COMMAND="${CFX_CMD} -P acfx_solver $CFX_OPT -par-dist"
	export COMMAND INTERACTIVE_SUPPORT
    /bin/sh -c "bsub  -app cfx -P ${PROJECT}  -B -N -J ${JOB_NAME} ${CWD_OPT} ${SUB_QUEUE_OPT} ${RUNHOST_OPT} ${NCPU_OPT} ${LSF_RESREQ} -o \"${OUTPUT_FILE_LOCATION}/output.%J\" ${EXTRA_PARAMS} ${CFX_CMD} -P acfx_solver"
fi
