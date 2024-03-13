# ECS Fargate Web Application

## About Application
A simple dockerized web app application deployed on ECS fargate with the following features
1. The infrasture was deployed using terraform as IAC
2. The application runs in private customer VPC
3. A custome sub-domain [https://makers.adeleke.org](https://makers.adeleke.org) with ssl certificate enabled 
4. The Cluster service was deployed to 2 availability zones for high availability
5. The ECS service ensure there are always two services running
6. ECR is used to host Docker images and pull to ECS
7. Access to the Cluster is only from the attached Application Load Balancer

## Application url
[https://makers.adeleke.org](https://makers.adeleke.org)

## Issues and Solution
Below are the problems found
1. 