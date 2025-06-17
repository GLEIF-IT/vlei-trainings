#!/bin/bash

# Direct mode Sally
export WEBHOOK_HOST=http://hook:9923
export DIRECT_SALLY_HOST=http://direct-sally:9823
export DIRECT_SALLY=direct-sally
export DIRECT_SALLY_ALIAS=directSally
export DIRECT_SALLY_PASSCODE=4TBjjhmKu9oeDp49J7Xdy
export DIRECT_SALLY_SALT=0ABVqAtad0CBkhDhCEPd514T
export DIRECT_SALLY_PRE=ECLwKe5b33BaV20x7HZWYi_KUXgY91S41fRL2uCaf4WQ
export GEDA_PRE=EC51WzzALD5d2PQl---qfZUVHLi3ldFLUNmHyMOjIRPC

# Check if vlei network exists, create it if not
# echo "Checking for keri_network..."
# if ! docker network ls | grep -q keri_network; then
#     echo "keri_network not found. Creating it..."
#     docker network create keri_network
# else
#     echo "keri_network already exists."
# fi

# Stop and remove existing containers, networks defined in the compose file
echo "Stopping and removing existing containers..."
docker compose down

# Build images (if Dockerfiles changed) and start services in detached mode
echo "Building images and starting containers..."
docker compose up --build -d

echo "Deployment complete!"
echo "Access JupyterLab at: http://localhost:8888"