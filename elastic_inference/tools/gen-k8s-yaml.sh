#!/bin/bash
###############################################################################
# Update "your-own-regitry" with given real registry name.
#
###############################################################################
curr_dir=$(readlink -f $(dirname "${BASH_SOURCE[0]}"))
top_dir=$(dirname "${curr_dir}")

function usage {
    cat << EOM
Usage: $(basename "$0") [OPTION]...

  -r your registry name
  -f your kubernetes template file
EOM
    exit 0
}

REGISTRY="docker.io"
TEMPLATE_FILE_PATH=""

function process_args {
    while getopts ":r:f:h" option; do
        case "${option}" in
            r) REGISTRY=${OPTARG};;
            f) TEMPLATE_FILE_PATH=$(readlink -f ${OPTARG});;
            h) usage;;
        esac
    done
}

process_args "$@"

TEMPLATE_FILE_NAME=$(basename ${TEMPLATE_FILE_PATH})
TEMPLATE_DIR=$(dirname ${TEMPLATE_FILE_PATH})
YAML_FILE_NAME=`echo "$TEMPLATE_FILE_NAME" | sed 's@.yaml.template@'_"$REGISTRY".yaml'@'`

echo "Registry: ${REGISTRY}"
echo "Template: ${TEMPLATE_FILE_NAME}"
echo "Yaml file: ${YAML_FILE_NAME}"

cp ${TEMPLATE_FILE_PATH} ${TEMPLATE_DIR}/${YAML_FILE_NAME}
sed -i -e 's/your-own-registry/'"$REGISTRY"'/g' ${TEMPLATE_DIR}/${YAML_FILE_NAME}

echo "Generate kubernete yaml file @${YAML_FILE_NAME} with registry ${REGISTRY}"
