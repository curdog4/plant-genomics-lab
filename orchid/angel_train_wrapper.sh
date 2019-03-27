#!/bin/bash

if [ "$CONDA_DEFAULT_ENV" != "angel" ]; then
    source activate lace
fi

echo "CONDA_DEFAULT_ENV=$CONDA_DEFAULT_ENV"

angel_train.py $@

exit 0
