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
    pushd ${top_dir} &> /dev/null

    echo "Check local .cache for download files ..."
    mkdir -p ${top_dir}/.cache
    cd ${top_dir}/.cache
    if [ ! -f ${top_dir}/.cache/Edge-optimized-models.zip ]; then
        echo "Download Edge-optimized-models.zip ..."
        wget --show-progress -O ${top_dir}/.cache/Edge-optimized-models.zip https://github.com/intel/Edge-optimized-models/archive/master.zip
        unzip ${top_dir}/.cache/Edge-optimized-models.zip
    fi

    if [ ! -f ${top_dir}/.cache/face-detection-retail-0005.xml ]; then
        echo "Download face-detection-retail-0005 ..."
        wget --show-progress https://download.01.org/opencv/2019/open_model_zoo/R2/20190628_180000_models_bin/face-detection-retail-0005/FP32/face-detection-retail-0005.xml
        wget --show-progress https://download.01.org/opencv/2019/open_model_zoo/R2/20190628_180000_models_bin/face-detection-retail-0005/FP32/face-detection-retail-0005.bin
    fi

    if [ ! -f ${top_dir}/.cache/face-detection-retail-0004.xml ]; then
        echo "Download face-detection-retail-0004 ..."
        wget --show-progress https://download.01.org/opencv/2019/open_model_zoo/R2/20190628_180000_models_bin/face-detection-retail-0004/FP32/face-detection-retail-0004.xml
        wget --show-progress https://download.01.org/opencv/2019/open_model_zoo/R2/20190628_180000_models_bin/face-detection-retail-0004/FP32/face-detection-retail-0004.bin
    fi

    if [ ! -f ${top_dir}/.cache/person-vehicle-bike-detection-crossroad-0078.xml ]; then
        echo "Download person-vehicle-bike-detection-crossroad-0078 ..."
        wget --show-progress https://download.01.org/opencv/2019/open_model_zoo/R2/20190628_180000_models_bin/person-vehicle-bike-detection-crossroad-0078/FP32/person-vehicle-bike-detection-crossroad-0078.bin
        wget --show-progress https://download.01.org/opencv/2019/open_model_zoo/R2/20190628_180000_models_bin/person-vehicle-bike-detection-crossroad-0078/FP32/person-vehicle-bike-detection-crossroad-0078.xml
    fi

    echo "Check extracted model files under ${top_dir}/models ..."
    if [ ! -d ${top_dir}/models ]; then
        mkdir -p ${top_dir}/models

        cp ${top_dir}/.cache/Edge-optimized-models-master/SqueezeNet\ 5-Class\ detection/FP32/* ${top_dir}/models
        cp ${top_dir}/.cache/Edge-optimized-models-master/MobileNet\ 5-Class\ detection/FP32/* ${top_dir}/models
        cp ${top_dir}/.cache/*.xml ${top_dir}/models
        cp ${top_dir}/.cache/*.bin ${top_dir}/models
    fi

    popd &> /dev/null
    echo "Success"
}

download_models
