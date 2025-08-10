#!/bin/bash
# Auto-detect and set CROSS_COMPILE path
set -e

# Try to find ARM64 cross-compiler
TOOLCHAIN_PATH=/home/aldin/coursera/arm-gnu-toolchain-13.3.rel1-x86_64-aarch64-none-linux-gnu/bin/aarch64-none-linux-gnu-

if [ -z "$TOOLCHAIN_PATH" ]; then
    echo "ERROR: No ARM64 cross-compiler found under /home/aldin/coursera"
    exit 1
fi

# Set CROSS_COMPILE without the gcc suffix
export CROSS_COMPILE="${TOOLCHAIN_PATH%gcc}"
echo "Using CROSS_COMPILE=$CROSS_COMPILE"

cd `dirname $0`
test_dir=`pwd`
echo "starting test with SKIP_BUILD=\"${SKIP_BUILD}\" and DO_VALIDATE=\"${DO_VALIDATE}\""

logfile=test.sh.log
exec > >(tee -i -a "$logfile") 2> >(tee -i -a "$logfile" >&2)

echo "Running test with user $(whoami)"

set +e

./unit-test.sh
unit_test_rc=$?
if [ $unit_test_rc -ne 0 ]; then
    echo "Unit test failed"
fi

if [ -f conf/assignment.txt ]; then
    assignment=`cat conf/assignment.txt`
    if [ -f ./assignment-autotest/test/${assignment}/assignment-test.sh ]; then
        echo "Executing assignment test script"
        ./assignment-autotest/test/${assignment}/assignment-test.sh $test_dir
        rc=$?
        if [ $rc -eq 0 ]; then
            echo "Test of assignment ${assignment} complete with success"
        else
            echo "Test of assignment ${assignment} failed with rc=${rc}"
            exit $rc
        fi
    else
        echo "No assignment-test script found for ${assignment}"
        exit 1
    fi
else
    echo "Missing conf/assignment.txt, no assignment to run"
    exit 1
fi
exit ${unit_test_rc}

