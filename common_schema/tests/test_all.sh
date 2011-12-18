#!/bin/bash
#
# Run all common_schema tests
#

export MYSQL_USER=$1
export MYSQL_PASSWORD=$2
export MYSQL_SOCKET=$3
export MYSQL_SCHEMA=common_schema

export INITIAL_PATH=$(pwd)
export TESTS_ROOT_PATH=${INITIAL_PATH}/root

export TEST_OUTPUT_PATH=/tmp
export TEST_OUTPUT_FILE=common_schema_test_output.txt
export DIFF_OUTPUT_FILE=common_schema_test_diff.txt

let num_tests=0

cd $TESTS_ROOT_PATH

if [ -f pre.sql ] ; then
	mysql --user=$MYSQL_USER --password=$MYSQL_PASSWORD --socket=$MYSQL_SOCKET $MYSQL_SCHEMA < pre.sql
	if [ $? -ne 0 ] ; then
	  echo "Test startup failed on pre.sql"
	  exit 1
	fi
fi

for TEST_FAMILY_PATH in $(find * -maxdepth 0 -type d)
do
	# Test family: suite of tests, testing a specific feature or feature set
	echo "Testing family: ${TEST_FAMILY_PATH}"
	cd $TESTS_ROOT_PATH/$TEST_FAMILY_PATH
	if [ -f pre.sql ] ; then
		mysql --user=$MYSQL_USER --password=$MYSQL_PASSWORD --socket=$MYSQL_SOCKET $MYSQL_SCHEMA < pre.sql
		if [ $? -ne 0 ] ; then
		  echo "Test family ${TEST_FAMILY_PATH} failed on pre.sql"
		  exit 1
		fi
	fi

	for TEST_PATH in $(find * -maxdepth 0 -type d)
	do
		# Particular test
		cd $TESTS_ROOT_PATH/$TEST_FAMILY_PATH/$TEST_PATH

		# verbose
		if [ -f description.txt ] ; then
			export TEST_BRIEF_DESCRIPTION="$(cat description.txt | head -n 1 | cut -c 1-60)"
		else
			export TEST_BRIEF_DESCRIPTION=""
		fi
		echo "  ${TEST_FAMILY_PATH}/${TEST_PATH}: ${TEST_BRIEF_DESCRIPTION}"
		
		# prepare test
		if [ -f pre.sql ] ; then
			mysql --user=$MYSQL_USER --password=$MYSQL_PASSWORD --socket=$MYSQL_SOCKET $MYSQL_SCHEMA < pre.sql
			if [ $? -ne 0 ] ; then
			  echo "Test ${TEST_FAMILY_PATH}/${TEST_PATH} failed on pre.sql"
			  exit 1
			fi
		fi
		
		# execute test code
		mysql --user=$MYSQL_USER --password=$MYSQL_PASSWORD --socket=$MYSQL_SOCKET $MYSQL_SCHEMA --silent --raw < test.sql > ${TEST_OUTPUT_PATH}/${TEST_OUTPUT_FILE}
		if [ $? -eq 0 ] ; then
			# check test results
			if [ -f error_expected.txt ] ; then
			  # error is expected. How come no error?
			  echo "Test ${TEST_FAMILY_PATH}/${TEST_PATH} failed on test.sql; expected error, found none"
			  exit 1
			fi
			if [ -f expected.txt ] ; then
				# There is an "expected.txt" file: results must match that file
				diff expected.txt ${TEST_OUTPUT_PATH}/${TEST_OUTPUT_FILE} > ${TEST_OUTPUT_PATH}/${DIFF_OUTPUT_FILE}
				if [ $? -ne 0 ] ; then
				  echo "** Test ${TEST_FAMILY_PATH}/${TEST_PATH} failed: unexpected output."
				  echo "**   Output:   ${TEST_OUTPUT_PATH}/${TEST_OUTPUT_FILE}"
				  echo "**   Expected: $(pwd)/expected.txt"
				  echo "**   Diff:     ${TEST_OUTPUT_PATH}/${DIFF_OUTPUT_FILE}"
				  
				  exit 1
				fi
			else
				# No explicit "expected.txt" result.
				# By default, we expect "1"
				TEST_RESULT=$(cat ${TEST_OUTPUT_PATH}/${TEST_OUTPUT_FILE})
				if [ "$TEST_RESULT" != "1" ] ; then
				  echo "Test ${TEST_FAMILY_PATH}/${TEST_PATH} failed: got $TEST_RESULT"
				  exit 1
				fi
	  		fi
		else
		  # Test executes with error
		  if [ -f error_expected.txt ] ; then
		      # error is expected
		  	  :
		  else
			  echo "Test ${TEST_FAMILY_PATH}/${TEST_PATH} failed on test.sql"
			  exit 1
		  fi
		fi

		# post test code (typically cleanup)
		if [ -f post.sql ] ; then
			mysql --user=$MYSQL_USER --password=$MYSQL_PASSWORD --socket=$MYSQL_SOCKET $MYSQL_SCHEMA < post.sql
			if [ $? -ne 0 ] ; then
			  echo "Test ${TEST_FAMILY_PATH}/${TEST_PATH} failed on post.sql"
			  exit 1
			fi
		fi
		let num_tests=num_tests+1
	done
	# Post family code (typicaly cleanup)
	if [ -f post.sql ] ; then
		mysql --user=$MYSQL_USER --password=$MYSQL_PASSWORD --socket=$MYSQL_SOCKET $MYSQL_SCHEMA < post.sql
		if [ $? -ne 0 ] ; then
		  echo "Test family ${TEST_FAMILY_PATH} failed on post.sql"
		  exit 1
		fi
	fi
done

cd $TESTS_ROOT_PATH
if [ -f post.sql ] ; then
	mysql --user=$MYSQL_USER --password=$MYSQL_PASSWORD --socket=$MYSQL_SOCKET $MYSQL_SCHEMA < post.sql
	if [ $? -ne 0 ] ; then
	  echo "Test cleanup failed on post.sql"
	  exit 1
	fi
fi

echo "Tests complete. Total num tests: ${num_tests}"

cd ${INITIAL_PATH}
