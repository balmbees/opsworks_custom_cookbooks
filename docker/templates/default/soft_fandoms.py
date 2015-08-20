from __future__ import print_function
import sys
import random
import json
import datetime

from pyspark import SparkContext
from pyspark.sql import SQLContext

date_str = (datetime.date.today()-datetime.timedelta(days=1)).strftime("%Y-%m-%d")

def split_with_taggings(obj):
  result = []
  for channel_id in obj["data"]["taggings"]:
    result.append( [(obj["data"]["user_id"], channel_id, obj["data"]["referral_area"] if obj["data"]["referral_area"] is not None else 0, obj["data"]["action"]),1] )
  return result

if __name__ == "__main__":
  sc = SparkContext(appName="spark_daily_uc_ctr")

  distFile = sc.textFile("s3n://vingle-logs/fluent-logs/production/soft_fandoms/2015/"+date_str+"/*")
  # read in line
  result = distFile.map(lambda line: line)
  result = result.map(lambda line: json.loads(line))
  # filter
  result = result.filter(lambda obj: obj["data"]["action"] != "card_leave")
  result = result.filter(lambda obj: obj["data"]["action"] != "publish")
  # label check
  result = result.filter(lambda obj: obj["label"] == "soft_fandom_from_post_v2")
  # map
  result = result.flatMap(split_with_taggings)
  # reduce
  result = result.reduceByKey(lambda a,b: a+b)
  result = result.map(lambda x: ((date_str,x[0][0],x[0][1],x[0][2]), (x[1] if x[0][3] == "card_impression" else 0, x[1] if x[0][3] == "card_read" else 0)))
  result = result.reduceByKey(lambda a,b: (a[0]+b[0],a[1]+b[1]))
  result = result.map(lambda obj: reduce(lambda x,y: x+y, map(list, obj)))
  result = result.map(lambda _list: "|".join(map(str,_list)))
  # aggregate
  result.saveAsTextFile("s3n://spark-outputs/spark_daily_uc_ctr/"+date_str+"/")

  # job done
  sc.stop()
