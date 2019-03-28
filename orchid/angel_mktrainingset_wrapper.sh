#!/bin/bash

if [ "$CONDA_DEFAULT_ENV" != "angel" ]; then
    source activate angel
fi

echo "CONDA_DEFAULT_ENV=$CONDA_DEFAULT_ENV"

angel_make_training_set.py $@

exit 0
