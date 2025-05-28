THE GOAL OF THE TASK:
 - create REST API docker
 - run application in ECS
 - create RDS MySQL database
 - application need access to the database
 - expose application to public network
 - application can access only from a specific public CIDR range

REPOSITORY CODE INFRASTRUCTURE

Considering application as 3 tier web application:
 - range 192.168.0.0/21
 - subnet prefix /24
    - database subnets for RDS
    - private subnets for ECS
    - public subnets for ALB

Created also module pipeline:
- can be used with terragrunt if multiple stages are required
- pipeline can be improved
    - create a docker application image, only if there is a change in application logic - not sure how?
    - added step which checks application functionality (not tested)
    - "canary" deployment- forward only small % of the traffic to the new application task before full- traffic switch
    - prerequisites for PIPELINE:
        - administrator role in destination AWS account
        - codestarconnection
        - github repository

Basic tagging used (project and stage)
- currently hardcoded, can be passed dynamically, using only one general tag-file

ALB uses generating certificate from ACM for HTTPS terminating
- not yet tested, requires additional configuration
- only basic configuration of ALB- need to dive deeper what can be useful?

There is a module which creates secret for RDS database
- for RDS module the credentials are passed dynamicaly
- for ECS module, task definition is created
    - credentials are not hardcoded
    - approach of minimum permission for ECS 

Security
 - security groups referencing each other only on a specific port
 - ALB SG allows 0.0.0.0/0 for testing purpose

APPLICATION CURENTLY USES REMOTE BACKEND
 - s3 bucket for remote backed tf state (need to redesign)

Docker application
 - application configuration with following functionalities:
    - post
    - get
    - delete
    - 8080 port
 - not yet tested, probably additional configuration, fix required (no experience)

Improvement:

If the application is business critical, customers are from all around the world or there is high peak of requests per second:

 - consider application high availability, resilient by deploying resources in multiple availability zones
    - code structure creates 2 subnets for database, application and load balancer
    - code structure (resources) are not optimized yet
        - only one DB without replica
        - only one ECS task
        - ALB covers only one subnet (there is not cross-zone load-balancing)
 - consider application with using Cloud Front together with ALB
 - from security POV consider of using WAF, NACL (not implemented)
 - consider backup of RDS/ application
    - define RTO and RPO
    - define DRP (disaester recovery scenario)
        - light, active-active, active- passive?
 - if multiple stages and robust solutions
    - aws management account for logical structure (pipelines, step functions)
    - aws stage accounts (resources- application & data)
        - repository for logical structure- tied with management account
        - repository modules- data structure
    - cross-account deployment
    - tagging: correct tagging like project, owner, repository, stage, department
        - useful when multiple organisations participate on development in the same account, same application or other application parts
