#!/bin/bash
#
#################################################
#
# Purpose: Test for a real wildland fire ingesting data from wrfoutput file
#
#################################################
#
purge_output=1 # 0) No, 1) yes
plot=0 # 0) No, 1) yes
#
#################################################
#
test6p1=1 # Check fire area
test6p2=1 # Check heat output
test6p3=1 # Check latent heat output
test6p4=1 # Check Max heat flux
test6p5=1 # Check Max latent heat flux
#
#################################################
#

file_wrf=./test6/rsl.out.0000
file_exe=../nuopc/esmApp.exe
file_output=test6_output.txt

cp ./test6/wrf.nc .
cp ./test6/namelist.input .
cp ./test6/geo_em.d01.nc .

rm -f  ./$file_output
if [ -f $file_exe ]
then
  $file_exe  > ./$file_output
else
  echo 'Please compile the code first'
  exit 1
fi

n_tests=0
n_test_passed=0

#
# ----------------------------------------
#

echo "TEST 6:"

if [ $test6p1 -eq 1 ]
then
  n_tests=$(expr $n_tests + 1)
  rm -f ./file1.dat ./file2.dat
  var="Fire area"
  grep "$var" $file_output  | awk '{print $2, $6}' > ./file1.dat
  grep "$var" $file_wrf     | awk '{print $2, $6}' > ./file2.dat

  test=$(diff ./file1.dat ./file2.dat | wc -l)
  if [ $test -eq 0 ]
  then
    echo '  Test6.1 PASSED'
    n_test_passed=$(expr $n_test_passed + 1)
  else
    echo '  Test6.1 FAILS'
  fi

fi

#
# ----------------------------------------
#

if [ $test6p2 -eq 1 ]
then
  n_tests=$(expr $n_tests + 1)
  rm -f ./file1.dat ./file2.dat
  var="Heat output"   # 6
  grep "$var" $file_output  | awk '{print $2, $6}' > ./file1.dat
  grep "$var" $file_wrf     | awk '{print $2, $6}' > ./file2.dat

  test=$(diff ./file1.dat ./file2.dat | wc -l)
    # Here we allow one difference since we are not expecting bit4bit results
  if [ $test -le 38 ]
  then
    echo '  Test6.2 PASSED'
    echo '    Ignore this difference:'
    diff ./file1.dat ./file2.dat
    n_test_passed=$(expr $n_test_passed + 1)
  else
    echo '  Test6.2 FAILS'
  fi
fi

#
# ----------------------------------------
#

if [ $test6p3 -eq 1 ]
then
  n_tests=$(expr $n_tests + 1)
  rm -f ./file1.dat ./file2.dat
  var="Latent heat output" # 7
  grep "$var" $file_output  | awk '{print $2, $7}' > ./file1.dat
  grep "$var" $file_wrf     | awk '{print $2, $7}' > ./file2.dat

  test=$(diff ./file1.dat ./file2.dat | wc -l)
  if [ $test -le 20 ]
  then
    echo '  Test6.3 PASSED'
    echo '    Ignore this difference:'
    diff ./file1.dat ./file2.dat
    n_test_passed=$(expr $n_test_passed + 1)
  else
    echo '  Test6.3 FAILS'
  fi
fi

#
# ----------------------------------------
#

if [ $test6p4 -eq 1 ]
then
  n_tests=$(expr $n_tests + 1)
  rm -f ./file1.dat ./file2.dat
  var="Max heat flux" # 7
  grep "$var" $file_output  | awk '{print $2, $7}' > ./file1.dat
  grep "$var" $file_wrf     | awk '{print $2, $7}' > ./file2.dat

  test=$(diff ./file1.dat ./file2.dat | wc -l)
    # Here we allow one difference since we are not expecting bit4bit results
  if [ $test -le 30 ]
  then
    echo '  Test6.4 PASSED'
    echo '    Ignore this difference:'
    diff ./file1.dat ./file2.dat
    n_test_passed=$(expr $n_test_passed + 1)
  else
    echo '  Test6.4 FAILS'
  fi
fi

#
# ----------------------------------------
#

if [ $test6p5 -eq 1 ]
then
  n_tests=$(expr $n_tests + 1)
  rm -f ./file1.dat ./file2.dat
  var="Max latent heat flux" # 8
  grep "$var" $file_output  | awk '{print $2, $8}' > ./file1.dat
  grep "$var" $file_wrf     | awk '{print $2, $8}' > ./file2.dat

  test=$(diff ./file1.dat ./file2.dat | wc -l)
    # Here we allow one difference since we are not expecting bit4bit results
  if [ $test -eq 8 ]
  then
    echo '  Test6.5 PASSED'
    echo '    Ignore this difference:'
    diff ./file1.dat ./file2.dat
    n_test_passed=$(expr $n_test_passed + 1)
  else
    echo '  Test6.5 FAILS'
  fi
fi

#
# ----------------------------------------
#

  # Purge
rm -f ./namelist.fire.output ./file1.dat ./file2.dat ./wrf_input.dat ./geo_em.d01.nc ./namelist.input
if [ $purge_output -eq 1 ]
then
  rm -rf ./$file_output
  rm -f ./fire_output_2012-06-25_18:00:??.nc
fi

  # Print summary of Test 6
if [ $n_test_passed -eq $n_tests ]
then
  echo "SUCCESS: $n_test_passed PASSED of $n_tests"
  echo ''
else
  echo "FAILED: $n_test_passed PASSED of $n_tests"
  echo ''
fi

  # plots
if [ $plot -eq 1 ]
then
  if [ -f ./latlons.dat -a -f ./latlons_c.dat -a -f ./wrf_latlons_atm.dat ]
  then
    ./test4/gn_latlons.s latlons.dat latlons_c.dat wrf_latlons_atm.dat
  fi

  if [ -f ./wrf_latlons_fire.dat -a -f ./latlons.dat -a -f ./wrf_latlons_atm.dat ]
  then
    ./test4/gn_latlons2.s wrf_latlons_fire.dat latlons.dat wrf_latlons_atm.dat
  fi
fi

rm -f ./latlons.dat ./latlons_c.dat ./wrf_latlons_atm.dat ./wrf_latlons_fire.dat
rm -f ./wrf.nc PET0.ESMF_LogFile
