#!/bin/bash
###############################################################################
# Download the existing models into <top_dir>/sample-videos folders.
#
# These videos come from https://github.com/intel-iot-devkit/sample-videos/
# under the Attribution 4.0 license (https://github.com/intel-iot-devkit/sample-videos/blob/master/LICENSE)
###############################################################################
curr_dir=$(readlink -f $(dirname "${BASH_SOURCE[0]}"))
top_dir=$(dirname "${curr_dir}")

function download_sample_videos {
    pushd ${top_dir}
    if [ ! -d ${top_dir}/sample-videos ]; then
        echo "Download sample videos..."
        wget https://github.com/intel-iot-devkit/sample-videos/archive/master.zip && unzip master.zip
        mv sample-videos-master sample-videos
        rm master.zip
    fi
    popd
}

download_sample_videos
