# AWS
AWS_ACCESS_KEY_ID?=AWS_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY?=AWS_SECRET_ACCESS_KEY
AWS_REGION?=AWS_REGION
AWS_ACCOUNT_ID?=AWS_ACCOUNT_ID
ENVIRONMENT?=mwa
# use the env var
ENVIRONMENT?=ENVIRONMENT

test-env:
	echo "environment is ${ENVIRONMENT}"

init-validate:
	terraform init; terraform validate;

create-backend:
	cd s3_state && terraform init; terraform fmt; terraform apply -auto-approve -var="environment=${ENVIRONMENT}";

destroy-backend:
	cd s3_state && terraform init; terraform destroy -auto-approve -var="environment=${ENVIRONMENT}";

plan-infra:
	terraform init; terraform validate; terraform plan -target=module.mwa -target=module.mwa_ecr -target=module.mwa_dynamodb -target=module.mwa_s3web -target=module.mwa_cognito -var="environment=${ENVIRONMENT}";

plan-dynamodb:
	terraform init; terraform validate; terraform plan -target=module.mwa_dynamodb -var="environment=${ENVIRONMENT}";

plan-ecs:
	terraform init; terraform validate; terraform plan -target=module.mwa_ecs -var="environment=${ENVIRONMENT}";

apply-infra:
	terraform init; terraform fmt; terraform apply -target=module.mwa -target=module.mwa_ecr -target=module.mwa_dynamodb -target=module.mwa_s3web -target=module.mwa_cognito -auto-approve -var="environment=${ENVIRONMENT}";

apply-dynamodb:
	terraform init; terraform fmt; terraform apply -target=module.mwa_dynamodb -auto-approve -var="environment=${ENVIRONMENT}";

apply-ecs:
	terraform init; terraform fmt; terraform apply -target=module.mwa_ecs -auto-approve -var="environment=${ENVIRONMENT}";

destroy-ecs:
	terraform init; terraform fmt; terraform destroy -target=module.mwa_ecs -auto-approve -var="environment=${ENVIRONMENT}";

destroy:
	terraform init; terraform destroy -auto-approve -var="environment=${ENVIRONMENT}"

clean:
	rm -rf .terraform; rm -rf s3_state/.terraform; rm -rf s3_state/terraform.tfstate; rm -rf s3_state/terraform.tfstate.backup; rm -rf stream_processor_lambda.zip;

authenticate-docker-ecr:
	aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.us-east-1.amazonaws.com

build-image: 
	cd ./code/awswa/module-3/app && docker build . -t ${AWS_ACCOUNT_ID}.dkr.ecr.us-east-1.amazonaws.com/mwa_ecr_repo/service:latest

push-image: authenticate-docker-ecr
	docker push ${AWS_ACCOUNT_ID}.dkr.ecr.us-east-1.amazonaws.com/mwa_ecr_repo/service:latest

describe-image-repo:
	aws ecr describe-images --repository-name mwa_ecr_repo/service

# run this target outside the devcontainer
run-container:
	docker run -p 8080:8080 ${AWS_ACCOUNT_ID}.dkr.ecr.us-east-1.amazonaws.com/mwa_ecr_repo/service:latest
	# browse to http://localhost:8080/mysfits

load-dynamodb:
	aws dynamodb batch-write-item --request-items file://code/awswa/module-3/aws-cli/populate-dynamodb.json

scan-dynamodb:
	aws dynamodb scan --table-name MysfitsTable

plan-s3deploy: init-validate
	terraform plan -target=module.mwa_s3deploy -var="environment=${ENVIRONMENT}";

apply-s3deploy: init-validate
	terraform apply -target=module.mwa_s3deploy -auto-approve -var="environment=${ENVIRONMENT}";

s3-deploy:
	aws s3 cp --recursive ./code/awswa/module-4/web s3://tdk-awssec-s3-web.io-${ENVIRONMENT}/
	aws s3 cp --recursive ./modules/s3deploy/jinja2_templates/output s3://tdk-awssec-s3-web.io-${ENVIRONMENT}/

s3-deploy-cleanup:
	rm -rf jinja2_templates/output/*

# not working
#verify:
	#until curl --quiet http://tdk-awssec-s3-web.io-mwa.s3-website-us-east-1.amazonaws.com | grep -q Snowflake; do echo "Waiting for backend to be ready..."; sleep 1; done

apply-all: apply-infra apply-s3deploy s3-deploy build-image push-image load-dynamodb apply-ecs

create-lambda-binary:
	cd ./code/awswa/module-5/app/streaming && pip install requests -t .
	zip stream_processor_lambda.zip ./code/awswa/module-5/app/streaming

plan-analytics: create-lambda-binary init-validate
	terraform plan -target=module.mwa_analytics -var="environment=${ENVIRONMENT}";

apply-analytics: create-lambda-binary init-validate
	terraform apply -target=module.mwa_analytics -var="environment=${ENVIRONMENT}";


