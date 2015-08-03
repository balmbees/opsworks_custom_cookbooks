#!/usr/bin/env ruby
session_file = Dir["/var/log/td-agent/buffer/td/session*"].first
if session_file and File.mtime(session_file) > Time.now - 60*5 # updated in 5 mins
  `/usr/local/bin/aws cloudwatch put-metric-data --namespace TdAgent --metric-name HealthyAgent --value 1 --unit "Count"`
else
  `/usr/local/bin/aws cloudwatch put-metric-data --namespace TdAgent --metric-name UnhealthyAgent --value 1 --unit "Count"`
end
