#!/bin/bash

DATA_SOURCE_DIR=/data/gpfs/assoc/pgl/data/orchid/Won/New_isoseq_results

declare -A SPEC_MAP
INDICES=""
for P in $DATA_SOURCE_DIR/*kb; do
  D=$(basename $P);
  PFX=${D:0:3}
  DST_PARENT_DIR=$(dirname */${D:0:3}_formatted_head.okay)
  if [ -z ${SPEC_MAP[$PFX]} ]; then
      echo "Destination parent directory $DST_PARENT_DIR"
      SPEC_MAP[$PFX]=$DST_PARENT_DIR
      INDICES="$PFX $INDICES"
  fi
done

function wait_jobmap()
{
    JOB_SUFFIX=$1
    echo "Waiting on submitted batch IDs: ${JOB_MAP[*]}"
    while [ -n "${JOB_MAP[*]}" ]; do
        for PFX in $INDICES; do
            JOB_NAME=${PFX}-${JOB_SUFFIX}
            JOB_ID=$(squeue -h -n ${JOB_NAME} -o "%F")
            if [ -z $JOB_ID ]; then
                unset JOB_MAP[$PFX]
            else
                echo "Waiting on job ${JOB_MAP[$PFX]} for $PFX..."
            fi
        done
        for i in {5..1}; do
            printf "\r%d" $i
            sleep 1
        done
        printf "\r"
    done
}

WORKDIR=$(cd $(dirname $0) && pwd)

##
# Generate CDS source FASTA from all available fragment length HQ and LQ reads
echo "Generating source CDS FASTA data..."
for PFX in $INDICES; do
    DATA_FILES=( $DATA_SOURCE_DIR/${PFX}*kb/*arrowed_{hq,lq}*.fasta.gz )
    echo "Source data files for ${PFX}: ${DATA_FILES[*]}"
    ROOT_DIR=${SPEC_MAP[$PFX]}/angel
    [ ! -d $ROOT_DIR ] && mkdir -p $ROOT_DIR
    OUTFILE=${ROOT_DIR}/${PFX}_all_cds.fasta
    if [ ! -f $OUTFILE ]; then
        echo "zcat ${DATA_FILES[*]} > $OUTFILE"
        zcat ${DATA_FILES[*]} > $OUTFILE
    fi
done

##
# Run ANGEL dumb prediction...
echo "Running ANGEL dumb prediction..."
declare -A JOB_MAP
for PFX in $INDICES; do
    ROOT_DIR=${SPEC_MAP[$PFX]}/angel
    OUT_DIR=${ROOT_DIR}/dumb
    [ ! -d $OUT_DIR ] && mkdir -p $OUT_DIR
    SRC_CDS=${ROOT_DIR}/${PFX}_all_cds.fasta
    if [ ! -f $SRC_CDS ]; then
        echo "ERROR: No source CDS found for $PFX" >&2
        continue
    fi
    DST_FILE=${OUT_DIR}/${PFX}_all_cds.dumb
    STDOUT=${OUT_DIR}/sbatch.out
    STDERR=${STDOUT/.out/.err}
    JOB_NAME=${PFX}-angel-dumb
    echo "Run ANGEL dumb prediction for $PFX"
    echo sbatch --account cpu-t1-pgl-0 --job-name=${JOB_NAME} --nodes=1 --ntasks=1 --cpus-per-task=16 --out $STDOUT --err $STDERR -D $WORKDIR \
         --wrap="./angel_dumb_predict_wrapper.sh $SRC_CDS $DST_FILE --cpus 16"
    sbatch --account cpu-t1-pgl-0 --job-name=${JOB_NAME} --nodes=1 --ntasks=1 --cpus-per-task=16 --out $STDOUT --err $STDERR -D $WORKDIR \
         --wrap="./angel_dumb_predict_wrapper.sh $SRC_CDS $DST_FILE --cpus 16"
    JOB_ID=$(squeue -h -n ${PFX}-angel-dumb -o "%F")
    JOB_MAP[$PFX]=$JOB_ID
done

wait_jobmap angel-dumb

##
# Create ANGEL non-redundant training dataset...
echo "Creating ANGEL non-redundant training data..."
declare -A JOB_MAP
for PFX in $INDICES; do
    ROOT_DIR=${SPEC_MAP[$PFX]}/angel
    OUT_DIR=${ROOT_DIR}/dumb-training
    [ ! -d $OUT_DIR ] && mkdir -p $OUT_DIR
    SRC_CDS=${ROOT_DIR}/dumb/${PFX}_all_cds.dumb
    if [ ! -f $SRC_CDS ]; then
        echo "ERROR: No dumb predictions found for $PFX" >&2
        continue
    fi
    DST_FILE=${OUT_DIR}/${PFX}_all_cds.dumb.training
    STDOUT=${OUT_DIR}/sbatch.out
    STDERR=${STDOUT/.out/.err}
    JOB_NAME=${PFX}-angel-dumb-training
    echo "Create ANGEL non-redundant dumb training for $PFX"
    echo sbatch --account cpu-t1-pgl-0 --job-name=${JOB_NAME} --nodes=1 --ntasks=1 --cpus-per-task=16 --out $STDOUT --err $STDERR -D $WORKDIR \
         --wrap="./angel_mktrainingset_wrapper.sh $SRC_CDS $DST_FILE --cpus 16"
    sbatch --account cpu-t1-pgl-0 --job-name=${JOB_NAME} --nodes=1 --ntasks=1 --cpus-per-task=16 --out $STDOUT --err $STDERR -D $WORKDIR \
         --wrap="./angel_mktrainingset_wrapper.sh $SRC_CDS $DST_FILE --cpus 16"
    JOB_ID=$(squeue -h -n ${PFX}-angel-dumb-training -o "%F")
    JOB_MAP[$PFX]=$JOB_ID
done

wait_jobmap angel-dumb-training

##
# Create ANGEL classifier dataset...
echo "Creating ANGEL classifier data..."
declare -A JOB_MAP
for PFX in $INDICES; do
    ROOT_DIR=${SPEC_MAP[$PFX]}/angel
    OUT_DIR=${ROOT_DIR}/classifier
    [ ! -d $OUT_DIR ] && mkdir -p $OUT_DIR
    SRC_CDS=${ROOT_DIR}/dumb-training/${PFX}_all_cds.dumb.final
    if [ ! -f $SRC_CDS ]; then
        echo "ERROR: no non-redundant training set found for $PFX" >&2
        continue
    fi
    DST_FILE=${OUT_DIR}/${PFX}_all_cds.dumb.final.training
    STDOUT=${OUT_DIR}/sbatch.out
    STDERR=${STDOUT/.out/.err}
    JOB_NAME=${PFX}-angel-classifier
    echo "Create ANGEL classifier for $PFX"
    echo sbatch --account cpu-t1-pgl-0 --job-name=${JOB_NAME} --nodes=1 --ntasks=1 --cpus-per-task=16 --out $STDOUT --err $STDERR -D $WORKDIR \
         --wrap="./angel_train_wrapper.sh $SRC_CDS $DST_FILE --cpus 16"
    sbatch --account cpu-t1-pgl-0 --job-name=${JOB_NAME} --nodes=1 --ntasks=1 --cpus-per-task=16 --out $STDOUT --err $STDERR -D $WORKDIR \
         --wrap="./angel_train_wrapper.sh $SRC_CDS $DST_FILE --cpus 16"
    JOB_ID=$(squeue -h -n ${PFX}-angel-classifier -o "%F")
    JOB_MAP[$PFX]=$JOB_ID
done

wait_jobmap angel-classifier

##
# Run ANGEL ORF prediction...
echo "Runnding ANGEL ORF prediction..."
declare -A JOB_MAP
for PFX in $INDICES; do
    ROOT_DIR=${SPEC_MAP[$PFX]}/angel
    OUT_DIR=${ROOT_DIR}/predict
    [ ! -d $OUT_DIR ] && mkdir -p $OUT_DIR
    SRC_CDS=${ROOT_DIR}/classifier/${PFX}_all_cds.dumb.final.training
    if [ ! -f $SRC_CDS ]; then 
        echo "ERROR: no classifier data found for $PFX" >&2
        continue
    fi
    DST_FILE=${OUT_DIR}/${PFX}_all_cds.final
    STDOUT=${OUT_DIR}/sbatch.out
    STDERR=${STDOUT/.out/.err}
    JOB_NAME=${PFX}-angel-predict
    echo "Create ANGEL classifier for $PFX"
    echo sbatch --account cpu-t1-pgl-0 --job-name=${JOB_NAME} --nodes=1 --ntasks=1 --cpus-per-task=16 --out $STDOUT --err $STDERR -D $WORKDIR \
         --wrap="./angel_predict_wrapper.sh $SRC_CDS $DST_FILE --cpus 16"
    sbatch --account cpu-t1-pgl-0 --job-name=${JOB_NAME} --nodes=1 --ntasks=1 --cpus-per-task=16 --out $STDOUT --err $STDERR -D $WORKDIR \
         --wrap="./angel_predict_wrapper.sh $SRC_CDS $DST_FILE --cpus 16"
    JOB_ID=$(squeue -h -n ${PFX}-angel-predict -o "%F")
    JOB_MAP[$PFX]=$JOB_ID
done

wait_jobmap angel-predict
