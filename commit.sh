#!/bin/bash
set -e

DIR=$(pwd)
BRANCH=newBranch
while getopts "mt" opt;do
	case $opt in
		m) BRANCH=master ;;
		t) TEST=true ;;
	esac
done
shift $((OPTIND-1))

if [ ! $# -ge 1 ];then echo "Enter at least one file";exit 1;fi
for i in $@;
	do if [ ! -f $DIR/$i ];then echo "$i is not a file";exit 1;fi
done

if [ ! -z $TEST ];then
	echo "Running unit tests"
	$PHOME/test.sh |awk '{print "["substr($0,32,3)"]: "substr($0,40,100)}'
	if [ ${PIPESTATUS[0]} -eq 1 ];then
		echo "Unit tests failed, aborting commit"
		exit 1
	fi
fi

echo "Starting commit"
cd $DIR/git
git checkout master
git pull
if [ $BRANCH == master ];then
	echo "Committing to master branch..."
else
	echo "Committing to $BRANCH..."
	if [[ $(git branch --list $BRANCH) ]];then
		git checkout $BRANCH
	else
		git checkout -b $BRANCH
	fi
fi

for i in $@;
	do cp $DIR/$i .
done
git diff *

git add .
read -p "Enter commit message: " MESSAGE
while [ -z "$MESSAGE" ]
	do read -p "Enter a non empty commit message: " MESSAGE
done
git commit -m "$MESSAGE"
git push -u origin $BRANCH

if [ $BRANCH == master ];then
	echo "Finished commit to master branch"
	exit 0
fi

read -p "Has the request been merged? Enter Y to proceed: " MERGED
while [[ -z "$MERGED" || ! "$MERGED" == [Yy] ]]
	do read -p "Has the request been merged? Enter Y to proceed: " MERGED
done
git checkout master
git pull
git push origin --delete $BRANCH
git branch -d $BRANCH
echo "Finished"
