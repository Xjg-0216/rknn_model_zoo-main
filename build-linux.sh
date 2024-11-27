#!/bin/bash

set -e

echo "$0 $@"

# 解析选项
while getopts ":d:b:m:r" opt; do
  case $opt in
    d)
      BUILD_DEMO_NAME=$OPTARG
      ;;
    b)
      BUILD_TYPE=$OPTARG
      ;;
    m)
      ENABLE_ASAN=ON
      ;;
    r)
      DISABLE_RGA=ON
      ;;
    :)
      echo "Option -$OPTARG requires an argument."
      exit 1
      ;;
    ?)
      echo "Invalid option: -$OPTARG"
      exit 1
      ;;
  esac
done

# 必要参数检查
if [ -z ${BUILD_DEMO_NAME} ]; then
  echo "$0 -d <build_demo_name> [-b <build_type>] [-m] [-r]"
  echo ""
  echo "    -d : demo name"
  echo "    -b : build_type (Debug/Release, 默认 Release)"
  echo "    -m : enable address sanitizer, 仅用于 Debug"
  echo "    -r : disable RGA, 使用 CPU 处理图像"
  echo "例如: $0 -d mobilenet -b Debug -m"
  exit 1
fi

# 默认值
BUILD_TYPE=${BUILD_TYPE:-Release}
ENABLE_ASAN=${ENABLE_ASAN:-OFF}
DISABLE_RGA=${DISABLE_RGA:-OFF}

# 确定 DEMO 路径
for demo_path in $(find examples -name ${BUILD_DEMO_NAME}); do
  if [ -d "$demo_path/cpp" ]; then
    BUILD_DEMO_PATH="$demo_path/cpp"
    break
  fi
done

if [ -z "${BUILD_DEMO_PATH}" ]; then
  echo "无法找到 DEMO: ${BUILD_DEMO_NAME}"
  echo "可选项:"
  for demo_path in $(find examples -name cpp); do
    dname=$(dirname "$demo_path")
    name=$(basename $dname)
    echo "$name"
  done
  exit 1
fi

# 构建路径和安装路径
ROOT_PWD=$(cd "$(dirname $0)" && pwd)
INSTALL_DIR=${ROOT_PWD}/install/${BUILD_DEMO_NAME}
BUILD_DIR=${ROOT_PWD}/build/${BUILD_DEMO_NAME}_${BUILD_TYPE}

echo "==================================="
echo "BUILD_DEMO_NAME=${BUILD_DEMO_NAME}"
echo "BUILD_DEMO_PATH=${BUILD_DEMO_PATH}"
echo "BUILD_TYPE=${BUILD_TYPE}"
echo "ENABLE_ASAN=${ENABLE_ASAN}"
echo "DISABLE_RGA=${DISABLE_RGA}"
echo "INSTALL_DIR=${INSTALL_DIR}"
echo "BUILD_DIR=${BUILD_DIR}"
echo "==================================="

# 创建构建和安装目录
mkdir -p ${BUILD_DIR}
rm -rf ${INSTALL_DIR}

# 进入构建目录并运行 CMake 和 Make
cd ${BUILD_DIR}
cmake ../../${BUILD_DEMO_PATH} \
    -DCMAKE_BUILD_TYPE=${BUILD_TYPE} \
    -DENABLE_ASAN=${ENABLE_ASAN} \
    -DDISABLE_RGA=${DISABLE_RGA} \
    -DCMAKE_INSTALL_PREFIX=${INSTALL_DIR}

make -j$(nproc)
make install

# 检查是否生成了 RKNN 模型文件
if [ -d "$INSTALL_DIR/model" ]; then
  suffix=".rknn"
  shopt -s nullglob
  files=("$INSTALL_DIR/model/"*"$suffix")
  shopt -u nullglob

  if [ ${#files[@]} -le 0 ]; then
    echo -e "无法在 \"$INSTALL_DIR/model\" 中找到 RKNN 模型文件，请检查！"
  fi
else
  echo -e "安装目录 \"$INSTALL_DIR\" 不存在，请检查！"
fi
