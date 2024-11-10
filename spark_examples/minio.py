from pyspark.sql import SparkSession

# Initialize Spark session
spark = SparkSession.builder \
    .appName("Read CSV from S3") \
    .config("spark.hadoop.fs.s3a.access.key", "GD5Lg2x7tLaGxShjozFw") \
    .config("spark.hadoop.fs.s3a.secret.key", "H7J3mn7pI6oK35Xpuyrv6Lk4AsgymaSiQ2zwdAlu") \
    .config("spark.hadoop.fs.s3a.endpoint", "http://192.168.18.115:9000") \
    .config("spark.hadoop.fs.s3a.path.style.access", "true") \
    .config("spark.hadoop.fs.s3a.impl", "org.apache.hadoop.fs.s3a.S3AFileSystem") \
    .config("spark.hadoop.fs.s3a.connection.ssl.enabled", "false") \
    .getOrCreate()

# Specify the S3 file path
s3_csv_path = "s3a://spark/allsales.csv"

# Read the CSV file
df = spark.read.csv(s3_csv_path, header=True, inferSchema=True)

# Show the DataFrame
df.show()
