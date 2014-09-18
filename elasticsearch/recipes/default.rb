#
# Cookbook Name:: elasticsearch
# Recipe:: default
#
# Copyright 2014, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#
#include_recipe "java"
include_recipe "#{cookbook_name}::elasticsearch"
include_recipe "#{cookbook_name}::kibana"
include_recipe "#{cookbook_name}::nginx"
