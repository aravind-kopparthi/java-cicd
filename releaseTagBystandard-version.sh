#!/bin/bash
#standard-version -a -i CHANGELOG.md --release-as 
checkTags(){

    git fetch --all
    tagCount=$(git tag --list | wc -l)
    if [${tagCount} -gt 0 ]; then
        preStandardCmd="standard-version --dry-run"
        StandardCmd="standard-version --dry-run"
    else
        preStandardCmd="standard-version --dry-run --first-release"
        StandardCmd="standard-version --first-release --dry-run"
    fi
}

preRelease(){
    checkTags
    preReleaseVersion=$(${preStandardCmd} | grep tagging | awk '{print $4}')
    releaseVersion=${preReleaseVersion:1}
    echo "Release version: is ${releaseVersion}"
    mvn org.codehaus.mojo:versions-maven-plugin:2.9.0:set  -DgenerateBackupPoms=false -DnewVersion="${releaseVersion}" -DprocessAllModules --quiet --batch-mode
    #git add '*pom.xml'
    #git commit -m "chore: update Release version to ${releaseVersion}"
}

release(){
    checkTags
    ${StandardCmd}
    #mvn -q -B versions:set -DgenerateBackupPoms=false -DnexSnapshot -DprocessAllModules
    mvn org.codehaus.mojo:versions-maven-plugin:2.9.0:set -DnextSnapshot=true -DprocessAllModules -DgenerateBackupPoms=false --quiet --batch-mode
    developVersion=$(mvn help:evaluate -Dexpression=project.version -q -DforceStdout)
    #mvn --quiet --batch-mode versions:set -DgenerateBackupPoms=false -DnexSnapshot -DnewVersion=5.6.0-SNAPSHOT  -DprocessAllModules
    #git add '*pom.xml'
    #git push --follow-tags origin HEAD$git_branch
}
git_branch=${2}

if [ "${1}" == "pre-release" ]; then
 preRelease
elif [ "${1}" == "release" ]; then
release
fi

