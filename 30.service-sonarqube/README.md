Steps to deploy Sonarqube on EKS

This repository contains helm charts ana script to deploy PostgreSQL, SonarQube, and Ingress using Helm charts on an EKS cluster. The script will also create the necessary Kubernetes secrets and apply an Ingress rule for sonarqube.


# Prerequisites

1. Kubernetes Cluster: Ensure you have an EKS cluster up and running.
2. kubectl: Ensure `kubectl` is installed and configured to interact with your cluster.
3. Helm: Ensure Helm is installed.

Clone the sonarqube repository to the local.

Postgres, Ingress-controller and Sonarqube will be deployed using deploy.sh script.

As part of this deployment deploy.sh script will create two namespaces(ingress and sonarqube) and it will create the secrets for posgresql and sonarqube for jdbc connectivity. 

It is advised to clone the repository to the /app path so that modifications to the deploy.sh script are not required.

Make sure all the helm charts are updated with the required resources(pod Resources and Storage resources) which can be modified in the values.yaml files of postgres and sonarqube.

Adjust the storage class accordingly, in the current helm chart the storage class used is gp2-ebs, This storage class can be modified in the values.yaml files of sonarqube and postgres.

Once the changes are completed, deploy.sh script can be executed.

# File Structure in deploy.sh Script

The current folder structure which is reffered in the deploy.sh script is below, please modify the paths accordingly where the helm charts are placed in your local machine. 
- `/app/postgresql`: Directory containing the Helm chart for PostgreSQL.
- `/app/sonarqube/sonarqube`: Directory containing the Helm chart for SonarQube.
- `/app/ingress-nginx`: Directory containing the Helm chart for Ingress.
- `/app/sonarqube/sonarqube/ingress-rule.yaml`: File containing the Ingress rules.
- `/app/postgresql/values.yaml`: Directory containing the values.yaml for PostgreSQL.
- `/app/sonarqube/sonarqube/values.yaml`: Directory containing the values.yamlfor SonarQube.
- `/app/ingress-nginx/values.yaml`: Directory containing the values.yaml for Ingress.
- `/app/sonarqube/sonarqube/ingress-rule.yaml`: File containing the Ingress rules.


# Secrets for Postgres and Sonarqube.
Before running the script, you will be prompted to provide the following secrets, JDBC username will be sonarqube:
- PostgreSQL Password           #creating password for postgresql
- JDBC Username for SonarQube   #username of postgresql which is sonarqube
- JDBC Password for SonarQube   #password of PostgreSQL

Give the executable permissions to the deploy.sh

```console
chmod +x deploy.sh
```

Execute the script.

```console
./deploy.sh
```
Above script will deploy Postgres, Ingress and Sonarqube and ingress rule.

Once script is completed, Please validate the pods status and ingress rule status, Make sure all pods are running using below commands.

```console
 kubectl get po -n sonarqube
 kubectl get po -n ingress
```

```console
 Make sure ingress rule has the loadbalancer mapped. This Loadbalancer DNS can be used for DNS mapping
 kubectl get ing -n sonarqube
```

NOTE: 
Application can be only accessed once DNS mapping has been completed. 
To test/access it temporarily change the svc type of sonarqube to LoadBalancer/NodePort from ClusterIP and revert it back to ClusterIP once testing is completed. 











