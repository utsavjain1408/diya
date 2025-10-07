## Application architecture
Your application will be a message-driven system with five microservices. 
1. ReactJS Frontend: A user interface with two pages. One page to submit new records and another to display them.
1. API Gateway (Go): A Go service that exposes RESTful endpoints for the frontend. It will receive data from the frontend form and publish a message to RabbitMQ.
1. Data Ingestion Service (Go): A Go service that consumes messages from RabbitMQ. When it receives a message, it will insert the new record into the MariaDB database.
1. Query Service (Go): A Go service that fetches records from the MariaDB database when requested by the API Gateway.
1. RabbitMQ: A message bus that handles the asynchronous communication between your services. This decouples the data ingestion from the user-facing API.
1. MariaDB: The persistent database for storing records. 
## Recommended toolings
1. Version Control: Git and GitHub for managing your codebase.
1. Code Editors: Visual Studio Code with extensions for Go, React, and Helm.
1. Go Development:
1. Echo or Fiber web framework for building the API services.
1. streadway/amqp library for integrating with RabbitMQ.
1. go-gorm/gorm or database/sql for database interactions with MariaDB.
1. React Development:
    - Vite for a fast and simple project setup.
    - React Router for managing navigation between your two pages.
    - Axios or the native Fetch API for making HTTP requests to your Go API Gateway.
1. Containerization: Docker to containerize each of your microservices.
1. Kubernetes and Helm:
1. Docker Desktop: The built-in Kubernetes cluster is perfect for your local development and testing.
1. Helm CLI: For developing and deploying your charts.
1. Helm Linter: A linter to ensure your Helm charts are well-formed and follow best practices.
1. Database Management:
    - A GUI tool like DBeaver for inspecting your MariaDB database.
    - The MariaDB Helm Chart from Bitnami can be used as a dependency in your umbrella chart to simplify deployment of the database service. 

## Project milestones
### Milestone 1: Core application functionality
#### Set up Go services:
- Create a Go module for each microservice (api-gateway, data-ingestion-service, query-service).
- Implement REST endpoints in the api-gateway service. For now, let the API Gateway directly call the other two Go services via HTTP, bypassing RabbitMQ.
- Implement the database logic in the data-ingestion-service and query-service to connect to and interact with MariaDB.
- Develop the React frontend:
#### Set up a React project.
- Create two components: one with a form for data insertion and another for listing records.
- Use Axios to call your Go API Gateway endpoints to submit form data and fetch existing records.
- Containerize the application:
    - Write a Dockerfile for each of your Go microservices and your React frontend.
    - Use a local docker-compose.yml file to spin up all your services and MariaDB for testing. 
### Milestone 2: Integrate message bus and refine microservices
#### Add RabbitMQ:
- Introduce RabbitMQ as a service in your docker-compose.yml.
- Modify the api-gateway to publish messages to a RabbitMQ exchange instead of directly calling the data ingestion service.
- Modify the data-ingestion-service to consume messages from a RabbitMQ queue.
- Ensure the query-service still fetches data from the database for the list page.
- Expert Helm chart development:
- Create the umbrella chart: Use helm create my-app to create the parent chart.
- Create sub-charts: Use helm create within the charts/ directory to create a sub-chart for each of your five microservices (React Frontend, API Gateway, Data Ingestion Service, Query Service, and RabbitMQ).
#### Add MariaDB dependency: In your umbrella Chart.yaml, add the MariaDB Bitnami chart as a dependency.
- Configure values: Use the values.yaml files for each chart and the umbrella chart to define environment variables, service ports, and deployment configurations. 
- Practice using conditional logic and template functions to master expert Helm features.
- Lint the charts: Use helm lint to validate your chart structure and configuration.
- Test local deployment: Deploy your umbrella chart to your Docker Desktop Kubernetes cluster using helm install. Verify that all pods are running and services are accessible. 
### Milestone 3: Testing and final polish
#### Functional testing:
1. Submit a new record through the React form and verify that it appears on the list page.
1. Test the application's resilience by temporarily stopping and restarting the data-ingestion-service to see if RabbitMQ properly holds and delivers messages once 1. the service is back up.

#### Helm chart advanced features:
- Custom resources: Define a ConfigMap or Secret in your sub-charts for a specific service's configuration.
- Ingress configuration: Configure an Ingress resource in your umbrella chart to manage external access to your API Gateway and frontend.
- Refine deployment:
- Explore GitOps for automated deployments. Tools like ArgoCD can be used to monitor your Git repository and automatically apply changes to your cluster.
Document your application, microservice responsibilities, and Helm chart structure. This will be an invaluable reference