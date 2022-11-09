# java-cicd
mvn clean package -DskipTests 
git rev-parse HEAD
git log -n 1 | grep commit | awk '{print $2}'
git log -n 1 | grep commit | awk '{print $2}' | cut -b 1-7
dev
mvn clean package -DskipTests -Dsha1=`git log -n 1 | grep commit | awk '{print $2}' | cut -b 1-7`

pre-release/master
mvn clean package -DskipTests -Dchangelist=''
release/master branch
mvn clean package -DskipTests -Dchangelist='RELEASE'



———

<parent>
        <artifactId>enterprise</artifactId>
        <groupId>com.group</groupId>
        <version>app-${revision}${sha1}${changelist}</version>
    </parent>

———
<properties>
 <revision>2.4.0</revision>
 <sha1></sha1>
        <changelist>-SNAPSHOT</changelist>
    </properties>



    <groupId>com.group</groupId>
    <artifactId>server</artifactId>
    <version>app-${revision}${sha1}${changelist}</version>
