#!/bin/sh

# Namespaces for the deployments
SONARQUBE_NAMESPACE="sonarqube"
INGRESS_NAMESPACE="ingress"

# Helm release names
POSTGRES_RELEASE="postgres"
SONARQUBE_RELEASE="sonarqube"
INGRESS_RELEASE="ingress"

# Paths to your local Helm chart directories
POSTGRES_CHART="/app/postgresql"  #Modify according to the local path of Postgres Helm chart
SONARQUBE_CHART="/app/sonarqube/sonarqube"  #Modify according to the local path of Sonarqube Helm chart
INGRESS_CHART="/app/ingress-nginx"   #Modify according to the local path of Ingress-nginx Helm chart

# Paths to your Helm chart values files
POSTGRES_VALUES="/app/postgresql/values.yaml"  #Modify according to the local path of Postgres values.yaml
SONARQUBE_VALUES="/app/sonarqube/sonarqube/values.yaml" #Modify according to the local path of Sonarqube values.yaml
INGRESS_VALUES="/app/ingress-nginx/values.yaml"  #Modify according to the local path of Ingress-nginx values.yaml

# Path to the Ingress rule file
INGRESS_RULE_FILE="/app/sonarqube/sonarqube/ingress-rule.yaml"  #Modify according to the local path of ingress rule file

# Prompt for secrets
echo "Enter PostgreSQL Password: "
read POSTGRES_PASSWORD
echo "Enter JDBC Username for SonarQube: "
read JDBC_USERNAME
echo "Enter JDBC Password for SonarQube: "
read JDBC_PASSWORD


# Create the namespaces if they don't exist
kubectl create namespace $SONARQUBE_NAMESPACE || true
kubectl create namespace $INGRESS_NAMESPACE || true

# Create SonarQube JDBC secret
echo "Creating SonarQube JDBC secret..."
kubectl create secret generic sonarqube-jdbc-secret \
	  --from-literal=jdbc-username=$JDBC_USERNAME \
	    --from-literal=jdbc-password=$JDBC_PASSWORD \
	      -n $SONARQUBE_NAMESPACE

# Create PostgreSQL secret
echo "Creating PostgreSQL secret..."
kubectl create secret generic postgresql-secret \
	  --from-literal=postgres-password=$POSTGRES_PASSWORD \
	    --from-literal=password=$POSTGRES_PASSWORD \
	      --from-literal=replication-password=$POSTGRES_PASSWORD \
	        -n $SONARQUBE_NAMESPACE

# Deploy PostgreSQL using the local chart
echo "Deploying PostgreSQL..."
helm upgrade --install $POSTGRES_RELEASE $POSTGRES_CHART \
	  --namespace $SONARQUBE_NAMESPACE \
	    --values $POSTGRES_VALUES

# Wait for PostgreSQL to be fully up and running
#echo "Waiting for PostgreSQL to be ready..."
#kubectl rollout status statefulset/${POSTGRES_RELEASE}-postgresql -n $SONARQUBE_NAMESPACE
echo "Waiting for 20 seconds for PostgreSQL to come up..."
sleep 20

# Deploy SonarQube using the local chart
echo "Deploying SonarQube..."
helm upgrade --install $SONARQUBE_RELEASE $SONARQUBE_CHART \
	  --namespace $SONARQUBE_NAMESPACE \
	    --values $SONARQUBE_VALUES

# Deploy Ingress using the local chart in the ingress namespace
#echo "Deploying Ingress..."
helm upgrade --install $INGRESS_RELEASE $INGRESS_CHART \
	  --namespace $INGRESS_NAMESPACE \
	    --values $INGRESS_VALUES

# Apply Ingress rule
echo "Applying Ingress rule..."
kubectl apply -f $INGRESS_RULE_FILE -n $SONARQUBE_NAMESPACE

echo "Deployment complete!"

