#!/bin/bash
#
# Run all common_schema tests
#

export INITIAL_PATH=$(pwd)
export TESTS_ROOT_PATH=${INITIAL_PATH}/root

cd $TESTS_ROOT_PATH
for TEST_TYPE_PATH in $(find . -mindepth 1 -maxdepth 1 -type d)
do
	# Test family: suite of tests, testing a specific feature or feature set
	cd $TESTS_ROOT_PATH/$TEST_TYPE_PATH
	if [ -f pre.sql ]
	then
		echo "found family pre.sql"
	else
		echo "no family pre.sql"
	fi
	for TEST_PATH in $(find . -mindepth 1 -maxdepth 1 -type d)
	do
		# Particular test
		cd $TESTS_ROOT_PATH/$TEST_TYPE_PATH/$TEST_PATH
		if [ -f pre.sql ]
		then
			echo "found test pre.sql"
		else
			echo "no test pre.sql"
		fi
	done
done
cd ${INITIAL_PATH}
