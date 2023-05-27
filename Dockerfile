# OS
FROM ubuntu:22.04

# 
LABEL author="spa"
LABEL maintainer="spa.skyson@gmail.com"
LABEL version="0.2"
LABEL description="Docker image for Jenkins with Android SDK"

# устанавливаем таймзону, чтоб Jenkins показывал локальное время
ENV TZ=Europe/Volgograd
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# i386 архитектуру для установки  ia32-libs
RUN dpkg --add-architecture i386

# обновляем пакеты и устанавливаем нужное
RUN apt-get update && apt-get install -y git \
 wget \
 sdkmanager \
 unzip \
 sudo \
 tzdata \
 locales\
 openjdk-19-jdk \
 libncurses5:i386 \
 libstdc++6:i386 \
 zlib1g:i386

#clear up
RUN apt-get clean && rm -rf /var/lib/apt/lists /var/cache/apt

#set local
RUN locale-gen en_US.UTF-8  
ENV LANG en_US.UTF-8  
ENV LANGUAGE en_US:en  
ENV LC_ALL en_US.UTF-8

#download and extract Android Sdk
ARG android_home_dir=/var/lib/android-sdk/
ARG sdk_tools_zip_file=platform-tools_r34.0.1-linux.zip
RUN mkdir $android_home_dir
RUN wget https://dl.google.com/android/repository/$sdk_tools_zip_file -P $android_home_dir -nv
RUN unzip $android_home_dir$sdk_tools_zip_file -d $android_home_dir
RUN rm $android_home_dir$sdk_tools_zip_file && chmod 777 -R $android_home_dir

#environment Android SDK
ENV ANDROID_HOME=$android_home_dir
ENV PATH="${PATH}:$android_home_dir/tools/bin:$android_home_dir/platform-tools"
ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64/

#licence Android SDK
RUN yes | sdkmanager --licenses

#work dir for Jenkins
ENV JENKINS_HOME=/var/lib/jenkins
RUN mkdir $JENKINS_HOME && chmod 777 $JENKINS_HOME

#заводим нового юзера с именем jenkins, сделаем его суперпользователем, переключимся на него и перейдем в рабочую директорию
RUN useradd -m jenkins && echo 'jenkins ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
USER jenkins
WORKDIR /home/jenkins

#загрузим и запустим war файл с последней версией Jenkins
RUN wget http://mirrors.jenkins.io/war-stable/latest/jenkins.war -nv
CMD java -jar jenkins.war

#open ports
EXPOSE 8080/tcp
