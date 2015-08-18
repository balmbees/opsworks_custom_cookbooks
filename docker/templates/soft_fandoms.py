from __future__ import print_function
import sys
import json
import datetime
from pyspark import SparkContext

date_str = datetime.date.today().strftime("%Y-%m-%d")

if __name__ == "__main__":
  sc = SparkContext(appName="soft_fandom_v2")
  distFile = sc.textFile("s3n://vingle-logs/fluent-logs/production/soft_fandoms/2015/"+date_str+"/*")
  result = distFile.map(lambda str: str).map(lambda line: json.loads(line)).flatMap(lambda obj: ["%s:%s" % (obj["data"]["user_id"],x) for x in obj["data"]["taggings"]]).map(lambda data: (data, 1)).reduceByKey(lambda a,b: a+b)
  result.saveAsTextFile("s3n://vingle-logs/flrngel/soft_fandoms/cookbook_test_"+date_str)

  sc.stop()
