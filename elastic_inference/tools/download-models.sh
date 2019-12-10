#!/bin/bash
###############################################################################
# Download the existing models into <top_dir>/models folders.
#
# These models comes from https://github.com/intel/Edge-optimized-models
# under the BSD license (https://github.com/intel/Edge-optimized-models/blob/master/LICENSE.txt)
###############################################################################
curr_dir=$(readlink -f $(dirname "${BASH_SOURCE[0]}"))
top_dir=$(dirname "${curr_dir}")

function download_models {
    pushd ${top_dir}
    if [ ! -d ${top_dir}/models ]; then
        echo "Download models..."
        wget https://github.com/intel/Edge-optimized-models/archive/master.zip
        unzip master.zip
        mkdir -p ${top_dir}/models
        cp Edge-optimized-models-master/SqueezeNet\ 5-Class\ detection/FP32/* models
        cp Edge-optimized-models-master/MobileNet\ 5-Class\ detection/FP32/* models
        rm Edge-optimized-models-master -fr
        rm master.zip
    fi
    popd
}

download_models
