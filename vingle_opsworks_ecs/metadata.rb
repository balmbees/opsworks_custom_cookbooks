name "vingle_opsworks_ecs"
description "Support for ECS"
maintainer "AWS OpsWorks"
license "Apache 2.0"
version "1.0.0"

recipe "vingle_opsworks_ecs::setup", "Install Amazon ECS agent."
recipe "vingle_opsworks_ecs::shutdown", "Remove Amazon ECS agent and docker."
recipe "vingle_opsworks_ecs::cleanup", "Remove Amazon ECS agent and docker."
recipe "vingle_opsworks_ecs::deploy", "Clean Up docker"
recipe "vingle_opsworks_ecs::undeploy", "not implemented"
recipe "vingle_opsworks_ecs::configure", "not implemented"
