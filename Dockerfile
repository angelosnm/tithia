FROM quay.io/jupyter/pyspark-notebook:spark-3.5.3

USER root

RUN wget -P /usr/local/spark-3.5.3-bin-hadoop3/jars https://repo1.maven.org/maven2/org/apache/hadoop/hadoop-aws/3.3.4/hadoop-aws-3.3.4.jar
RUN wget -P /usr/local/spark-3.5.3-bin-hadoop3/jars https://repo1.maven.org/maven2/com/amazonaws/aws-java-sdk-bundle/1.12.777/aws-java-sdk-bundle-1.12.777.jar
RUN wget -P /usr/local/spark-3.5.3-bin-hadoop3/jars https://repo.maven.apache.org/maven2/org/apache/sedona/sedona-common/1.6.1/sedona-common-1.6.1.jar

USER jovyan
