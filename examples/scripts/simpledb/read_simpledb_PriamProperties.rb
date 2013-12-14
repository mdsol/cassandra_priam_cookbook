#!/usr/bin/env ruby
require 'fog'
require 'pp'

keys = Hash[File.read("./awscredential.properties.example").split.map{|e| e.split("=") }]
sdb = Fog::AWS::SimpleDB.new(:aws_access_key_id => keys["AWSACCESSID"], :aws_secret_access_key => keys["AWSKEY"])

PriamProperties = sdb.select("select * from PriamProperties")
pp PriamProperties


