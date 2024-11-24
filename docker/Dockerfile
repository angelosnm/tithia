FROM quay.io/jupyter/all-spark-notebook:spark-3.5.2

USER root

# Update the package list and install Java 8 (required by Scala and Spark)
RUN apt-get update && apt-get install -y software-properties-common openjdk-8-jre

# Set JAVA_HOME environment variable
ENV JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64/

# Optionally add JAVA_HOME to the PATH
ENV PATH="$JAVA_HOME/bin:$PATH"

# Add the repository for GIS dependencies
RUN add-apt-repository ppa:ubuntugis/ubuntugis-unstable

# Install GIS dependencies
RUN apt-get update && apt-get install -y libgdal-dev libgeos-dev libproj-dev

# Install Scala
ENV SCALA_VERSION=2.12.18
ENV SCALA_HOME=/usr/local/scala
RUN wget https://downloads.lightbend.com/scala/${SCALA_VERSION}/scala-${SCALA_VERSION}.tgz && \
    tar -xvzf scala-${SCALA_VERSION}.tgz -C /usr/local && \
    mv /usr/local/scala-${SCALA_VERSION} ${SCALA_HOME} && \
    rm scala-${SCALA_VERSION}.tgz
ENV PATH="${SCALA_HOME}/bin:${PATH}"

# Download additional Spark jars
RUN wget -P /usr/local/spark/jars https://repo1.maven.org/maven2/org/apache/hadoop/hadoop-aws/3.3.4/hadoop-aws-3.3.4.jar
RUN wget -P /usr/local/spark/jars https://repo1.maven.org/maven2/com/amazonaws/aws-java-sdk-bundle/1.12.777/aws-java-sdk-bundle-1.12.777.jar

RUN wget -P /usr/local/spark/jars https://repo1.maven.org/maven2/org/apache/sedona/sedona-spark-3.5_2.12/1.6.1/sedona-spark-3.5_2.12-1.6.1.jar
RUN wget -P /usr/local/spark/jars https://repo1.maven.org/maven2/org/datasyslab/geotools-wrapper/1.6.1-28.2/geotools-wrapper-1.6.1-28.2.jar

USER $NB_USER

# Copy the project files
COPY . .

# Install Python dependencies
RUN pip install -r requirements.txt && rm requirements.txt
