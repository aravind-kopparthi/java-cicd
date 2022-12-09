
#!/bin/bash

#get highest tag number that starts with v
#Script that will find the last Git Tag and increment it. It will only increment when the latest commit does not already have a tag. 
#By default it increments the patch number, you can tell it to change the major or minor versions by adding #major or #minor to the commit message.
#git tag --list --sort=-version:refname "v*" | head -n 1
#git describe --match "v[0-9]*" --abbrev=4 HEAD
# git ls-remote --tags origin  
git fetch --tags -f
#VERSION=`git describe --match "RC-[0-9]*" --abbrev=0 --tags`
VERSION=`git describe --match "v[0-9].[0-9].[0-9]" --abbrev=0 --tags`
retVal=$?
if [ $retVal -ne 0 ]; then
    VNUM1=0
    VNUM2=0
    VNUM3=0
    developVersion=$(mvn help:evaluate -Dexpression=revision -q -DforceStdout)
    VERSION_BITS=(${developVersion//./ })
    echo $VERSION_BITS
    #get number parts and increase last one by 1
    VNUM1=${VERSION_BITS[0]}
    VNUM2=${VERSION_BITS[1]}
    VNUM3=${VERSION_BITS[2]}
else
   
    #replace . with space so can split into an array
 
    VERSION_BITS=(${VERSION//./ })
    #get number parts and increase last one by 1
    VNUM1=${VERSION_BITS[0]}
    VNUM2=${VERSION_BITS[1]}
    VNUM3=${VERSION_BITS[2]}
    VNUM1=`echo $VNUM1 | sed 's/v//'`
 
fi
# Check for #major or #minor in commit message and increment the relevant version number
MAJOR=`git log --format=%B -n 1 HEAD | grep '#major'`
MINOR=`git log --format=%B -n 1 HEAD | grep '#minor'`

if [ "$MAJOR" ]; then
    echo "Update major version"
    VNUM1=$((VNUM1+1))
    VNUM2=0
    VNUM3=0
elif [ "$MINOR" ]; then
    echo "Update minor version"
    VNUM2=$((VNUM2+1))
    VNUM3=0
else
    echo "Update patch version"
    VNUM3=$((VNUM3+1))
fi



#create new tag
NEW_VERSION="$VNUM1.$VNUM2.$VNUM3"
NEW_TAG="v$NEW_VERSION"

echo "Updating $VERSION to $NEW_TAG"

#get current hash and see if it already has a tag
"GIT_COMMIT"=`git rev-parse HEAD`
NEEDS_TAG=`git describe --contains $GIT_COMMIT`

#only tag if no tag already (would be better if the git describe command above could have a silent option)
if [ -z "$NEEDS_TAG" ]; then
    echo "Tagged with $NEW_TAG (Ignoring fatal:cannot describe - this means commit is untagged) "
    #cat pom.xml | sed -e "s%<revision>0.0.1-SNAPSHOT</revision>%<util.version>$bamboo_planRepository_branch</util.version>%" > pom.xml.transformed;
    cat pom.xml | sed -e  "s/<revision>.*<\\/revision>/<revision>${NEW_VERSION}<\\/revision>/g" > pom.xml.transformed
    rm pom.xml;
    mv pom.xml.transformed pom.xml;

   # git tag $NEW_TAG
   #git add '*pom.xml'
   #git commit -m "$gitCommit"
   #git push --follow-tags origin HEAD:$git_branch
else
    echo "Already a tag on this commit"
fi
