#!/bin/bash
###############################################################################
# Download the existing models into <top_dir>/models folders.
#
# These models comes from https://github.com/intel/Edge-optimized-models
# under the BSD license (https://github.com/intel/Edge-optimized-models/blob/master/LICENSE.txt)
###############################################################################
curr_dir=$(readlink -f $(dirname "${BASH_SOURCE[0]}"))
top_dir=$(dirname "${curr_dir}")

download_url="https://download.01.org/opencv/2019/open_model_zoo/R2/20190628_180000_models_bin"
model_names=( \
    "face-detection-retail-0005" \
    "person-vehicle-bike-detection-crossroad-0078" \
    )

function download_file {
    if [ ! -f $1 ]; then
        wget -O $1 --show-progress $2
    fi
}

function download_model {
    download_file $1_FP32.xml ${download_url}/$1/FP32/$1.xml
    download_file $1_FP32.bin ${download_url}/$1/FP32/$1.bin

    download_file $1_INT8.xml ${download_url}/$1/INT8/$1.xml
    download_file $1_INT8.bin ${download_url}/$1/INT8/$1.bin
}

function download_models {
    pushd ${top_dir} &> /dev/null

    echo "Check local .cache for download files ..."
    mkdir -p ${top_dir}/.cache
    cd ${top_dir}/.cache
    if [ ! -f ${top_dir}/.cache/Edge-optimized-models.zip ]; then
        echo "Download Edge-optimized-models.zip ..."
        download_file Edge-optimized-models.zip https://github.com/intel/Edge-optimized-models/archive/master.zip
        unzip ${top_dir}/.cache/Edge-optimized-models.zip
    fi

    for model in "${model_names[@]}"; do
        echo "Download model ${model} ..."
        download_model ${model}
    done

    #if [ ! -f ${top_dir}/.cache/face-detection-retail-0005.xml ]; then
    #    echo "Download face-detection-retail-0005 ..."
    #    wget --show-progress https://download.01.org/opencv/2019/open_model_zoo/R2/20190628_180000_models_bin/face-detection-retail-0005/FP32/face-detection-retail-0005.xml
    #    wget --show-progress https://download.01.org/opencv/2019/open_model_zoo/R2/20190628_180000_models_bin/face-detection-retail-0005/FP32/face-detection-retail-0005.bin
    #fi

    #if [ ! -f ${top_dir}/.cache/face-detection-retail-0005_INT8.xml ]; then
    #    echo "Download face-detection-retail-0004 ..."
    #    wget -O face-detection-retail-0005_INT8.xml --show-progress https://download.01.org/opencv/2019/open_model_zoo/R2/20190628_180000_models_bin/face-detection-retail-0005/INT8/face-detection-retail-0005.xml
    #    wget -O face-detection-retail-0005_INT8.bin --show-progress https://download.01.org/opencv/2019/open_model_zoo/R2/20190628_180000_models_bin/face-detection-retail-0005/INT8/face-detection-retail-0005.bin
    #fi

    #if [ ! -f ${top_dir}/.cache/person-vehicle-bike-detection-crossroad-0078.xml ]; then
    #    echo "Download person-vehicle-bike-detection-crossroad-0078 ..."
    #    wget --show-progress https://download.01.org/opencv/2019/open_model_zoo/R2/20190628_180000_models_bin/person-vehicle-bike-detection-crossroad-0078/FP32/person-vehicle-bike-detection-crossroad-0078.bin
    #    wget --show-progress https://download.01.org/opencv/2019/open_model_zoo/R2/20190628_180000_models_bin/person-vehicle-bike-detection-crossroad-0078/FP32/person-vehicle-bike-detection-crossroad-0078.xml
    #fi

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
