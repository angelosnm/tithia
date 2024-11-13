FROM quay.io/jupyter/all-spark-notebook:spark-3.5.3

USER root

RUN apt-get update && apt-get install -y software-properties-common openjdk-8-jre

RUN add-apt-repository ppa:ubuntugis/ubuntugis-unstable

RUN sudo apt-get update && sudo apt-get install libgdal-dev libgeos-dev libproj-dev -y

RUN wget -P /usr/local/spark-3.5.3-bin-hadoop3/jars https://repo1.maven.org/maven2/org/apache/hadoop/hadoop-aws/3.3.4/hadoop-aws-3.3.4.jar
RUN wget -P /usr/local/spark-3.5.3-bin-hadoop3/jars https://repo1.maven.org/maven2/com/amazonaws/aws-java-sdk-bundle/1.12.777/aws-java-sdk-bundle-1.12.777.jar
RUN wget -P /usr/local/spark-3.5.3-bin-hadoop3/jars https://repo1.maven.org/maven2/org/apache/sedona/sedona-spark-shaded-3.5_2.13/1.6.1/sedona-spark-shaded-3.5_2.13-1.6.1.jar
RUN wget -P /usr/local/spark-3.5.3-bin-hadoop3/jars https://repo1.maven.org/maven2/org/datasyslab/geotools-wrapper/1.6.1-28.2/geotools-wrapper-1.6.1-28.2.jar

USER $NB_USER

COPY . . 

RUN pip install -r requirements.txt && rm requirements.txt
