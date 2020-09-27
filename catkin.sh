#!/bin/bash
# version="v0.0.1 first version: add test functions. By:gqp."
# version="v0.0.2 Change to AVOS_X version. By:gqp."
version="v0.0.3 Compate with none-unit-test operation. By:gqp."
source ~/.bashrc

test_html_result_dir="test_result"
test_info_path="${test_html_result_dir}/unittest.info"

function prepare_coverage(){
  catkin_make -DCMAKE_BUILD_TYPE=Release --pkg mainstream_msgs -DCMAKE_CXX_FLAGS=" -fprofile-arcs -ftest-coverage -lgcov" --cmake-args -DUSE_TEST=ON
  catkin_make -DCMAKE_BUILD_TYPE=Release --pkg ivlocmsg -DCMAKE_CXX_FLAGS=" -fprofile-arcs -ftest-coverage -lgcov" --cmake-args -DUSE_TEST=ON
  catkin_make -DCMAKE_BUILD_TYPE=Release --pkg perception_msgs -DCMAKE_CXX_FLAGS=" -fprofile-arcs -ftest-coverage -lgcov" --cmake-args -DUSE_TEST=ON
  catkin_make -DCMAKE_BUILD_TYPE=Release --pkg velodyne_msgs -DCMAKE_CXX_FLAGS=" -fprofile-arcs -ftest-coverage -lgcov" --cmake-args -DUSE_TEST=ON
  catkin_make -DCMAKE_BUILD_TYPE=Release -DCMAKE_CXX_FLAGS=" -fprofile-arcs -ftest-coverage -lgcov" --cmake-args -DUSE_TEST=ON
}

function run_test(){
  catkin_make run_tests --cmake-args -DUSE_TEST=ON
}
function make_cover(){
  lcov -q -d build -b . --rc lcov_branch_coverage=1 --no-external -f -c -o $test_info_path
}
function run_html(){
  genhtml -o  $test_html_result_dir -f --rc lcov_branch_coverage=1 --prefix='pwd' $test_info_path
}
function run_all(){
  #run_test
  catkin_make run_tests --cmake-args -DUSE_TEST=ON
  lcov -q -d build -b . --rc lcov_branch_coverage=1 --no-external -f -c -o $test_info_path
  #make_cover
  prepare_coverage
  #run_html
  genhtml -o  $test_html_result_dir -f --rc lcov_branch_coverage=1 --prefix='pwd' $test_info_path
}

function make_release(){
  catkin_make -DCMAKE_BUILD_TYPE=Release --pkg mainstream_msgs --cmake-args -DUSE_TEST=OFF
  catkin_make -DCMAKE_BUILD_TYPE=Release --pkg ivlocmsg --cmake-args -DUSE_TEST=OFF
  catkin_make -DCMAKE_BUILD_TYPE=Release --pkg perception_msgs  --cmake-args -DUSE_TEST=OFF
  catkin_make -DCMAKE_BUILD_TYPE=Release --pkg velodyne_msgs --cmake-args -DUSE_TEST=OFF
  catkin_make -DCMAKE_BUILD_TYPE=Release --cmake-args -DUSE_TEST=OFF
  guardian_path="src/guardian/build"
  if [ ! -d "$guardian_path" ];then
    mkdir -p $guardian_path/
  else
    rm $guardian_path/* -fr
  fi
  origin_path=`pwd`
  cd $guardian_path
  cmake ..
  make
  cd $origin_path
}


function print_help(){
  BOLD='\033[1m'
  NONE='\033[0m'
  echo -e "catkin_make tools, functions:"
  echo -e "${BOLD}mr|make_release ${NONE}: Make release version of target."
  echo -e "${BOLD}ra|run_all ${NONE}: Run all step in gtest and coverage html generation."
  echo -e "${BOLD}rt|run_test ${NONE}: Just run gtest."
  echo -e "${BOLD}mc|make_cover ${NONE}: Generate coverage information."
  echo -e "${BOLD}mg|make_gui ${NONE}: Generate coverage gui (html files)."
  echo -e "${BOLD}h|help ${NONE}: Print help messages."
  echo -e "Version messages:"
  echo -e "${version}"
}

  cmd=$1
  shift

  case $cmd in
    -mr|mr|make_release)
      make_release $@
      ;;
    -pcv|pcv|prepare_coverage)
      prepare_coverage $@
      ;;
    -ra|ra|run_all)
      run_all $@
      ;;
    -rt|rt|run_test)
      run_test $@
      ;;
    -mc|mc|make_cover)
      make_cover $@
      ;;
    -mg|mg|make_gui)
      run_html $@
      ;;
    -h|h|help)
      print_help $@
      ;;
    *)
      make_release
      ;;
  esac

  # main $@
