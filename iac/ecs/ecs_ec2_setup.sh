yum -y update

curl -sL https://rpm.nodesource.com/setup_12.x | bash -
yum clean all && yum makecache fast
yum install -y deltarpm gcc-c++ make
yum install -y nodejs


yum install -y zip unzip
yum install -y git curl tar wget make gzip zip zlib-devel gcc openssl-devel bzip2-devel libffi-devel file hostname

cd /tmp && curl -o ibm-java-x86_64-sdk-8.0-6.6.bin http://public.dhe.ibm.com/ibmdl/export/pub/systems/cloud/runtimes/java/8.0.6.6/linux/x86_64/ibm-java-x86_64-sdk-8.0-6.6.bin

cat <<EOF > /tmp/ibm_java_install_response_file
# Sat Mar 14 19:10:17 UTC 2020
# Replay feature output
# ---------------------
# This file was built by the Replay feature of InstallAnywhere.
# It contains variables that were set by Panels, Consoles or Custom Code.



#Indicate whether the license agreement been accepted
#----------------------------------------------------
LICENSE_ACCEPTED=TRUE

#Choose Install Folder
#---------------------
USER_INSTALL_DIR=/opt/ibm/java-x86_64-80

#Install
#-------
-fileOverwrite_/opt/ibm/java-x86_64-80/_uninstall/uninstall.lax=Yes
EOF

chmod +x /tmp/ibm-java-x86_64-sdk-8.0-6.6.bin
/tmp/ibm-java-x86_64-sdk-8.0-6.6.bin -i silent -f /tmp/ibm_java_install_response_file


export JAVA_HOME=/opt/ibm/java-x86_64-80
export PATH=$JAVA_HOME/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
export CONTAINER=`docker ps|grep camel|awk '{print $1}'`
export `docker inspect $CONTAINER|grep AWS_CONTAINER_CREDENTIALS_RELATIVE_URI| cut -d \" -f2`

cp `find /var -name broker-1.0-SNAPSHOT.jar -print` .
cp `find /var -name server-chain.jks -print` .
