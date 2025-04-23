# MySQL to Iceberg Sync via OLake + Hive + Spark

This project demonstrates how I built a pipeline that extracts data from a MySQL database, syncs it into Apache Iceberg using OLake CLI with Hive Metastore integration, and queries it using Apache Spark.

The task looked simple at first, but I ran into a bunch of roadblocks that made it a deeper learning experience.

---

I started by setting up a MySQL container using Docker. The basic command was straightforward, but once I tried to connect to it from inside the container using the `docker exec` command, I kept hitting this error:


Turns out I had confused running MySQL *in* the container vs trying to connect as if I were on the host OS. The fix was to specify the host and port explicitly — and make sure the MySQL server was fully up and running.

Next, I inserted a small dataset into a `shop.orders` table. I kept the schema simple: id, customer_name, product, quantity, order_date. After loading ~10 sample rows, I moved on to setting up the Hive Metastore.

Here came one of the biggest pain points. Most tutorials online assume you're using a fully bundled Hadoop environment or something like Cloudera, but I needed just Hive Metastore, standalone. I tried:

```bash
docker run -d --name hive-metastore -p 9083:9083 ...
```

But the image metastore-image didn't exist. I then figured out I could use the Bitnami Hive Metastore image instead:

docker run -d --name hive-metastore \
  -p 9083:9083 \
  -e HIVE_METASTORE_USER=hive \
  -e HIVE_METASTORE_PASSWORD=hive \
  bitnami/hive-metastore:latest

Even then, Hive didn’t start instantly — it needed some time to boot. I had to tail logs using docker logs -f hive-metastore to ensure it was ready. Only then did OLake CLI stop throwing connection errors.

I set the environment variable:

export OLAKE_HIVE_METASTORE_URI=thrift://localhost:9083

Then used OLake to discover the MySQL schema:

```bash
olake discover mysql \
  --host localhost \
  --port 3306 \
  --username root \
  --password root \
  --database shop \
  --table orders
  ```

The discover step worked fine, but syncing gave me a bit of a headache. I had to figure out the correct path to the Iceberg warehouse and also realize that the Hive Metastore needs to be aware of it. I used:

```bash
olake sync mysql \
  --host localhost \
  --port 3306 \
  --username root \
  --password root \
  --database shop \
  --table orders \
  --target iceberg \
  --hive-metastore thrift://localhost:9083 \
  --iceberg-warehouse /user/hive/warehouse
  ```

Initially, I was using local paths (like /tmp/iceberg) and got errors because Hive was not able to register tables there — only HDFS-style paths worked in this context.

Finally, I queried the synced Iceberg table using Spark. Configuring Spark to recognize Hive-backed Iceberg tables was a bit of a maze. I used this setup:

```bash

spark-sql \
  --conf spark.sql.catalog.olake=org.apache.iceberg.spark.SparkCatalog \
  --conf spark.sql.catalog.olake.type=hive \
  --conf spark.sql.catalog.olake.uri=thrift://localhost:9083

  ```


This is where I hit a major roadblock. The command executed fine, but when I tried querying the orders table, I didn’t get any data back. The issue was rooted in a few configuration details that I hadn’t accounted for in the Spark setup. Despite my best efforts to adjust the catalog configurations, I couldn’t fetch the data from the Iceberg table as expected.

I tried several troubleshooting steps, including checking the Hive Metastore connection, verifying Iceberg paths, and even re-syncing the data. Unfortunately, after spending quite a bit of time debugging this issue, I couldn’t retrieve the synced data through Spark SQL, which meant I was unable to proceed with verifying the complete pipeline.

