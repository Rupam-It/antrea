#!/bin/bash

# Get the Antrea controller pod
controller_pod=$(kubectl get pods -n kube-system -l app=antrea,component=antrea-controller -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)
if [ $? -ne 0 ] || [ -z "$controller_pod" ]; then
  echo "No Antrea controller pod found."
else
  kubectl logs -n kube-system $controller_pod | head -n 10 > controller.txt
  echo "Saved first 10 lines of $controller_pod logs to controller.txt"
fi

# Get the Antrea agent pods
agent_pods=$(kubectl get pods -n kube-system -l app=antrea,component=antrea-agent -o jsonpath='{range .items[*]}{.metadata.name}{"\n"}{end}' 2>/dev/null)
if [ $? -ne 0 ] || [ -z "$agent_pods" ]; then
  echo "No Antrea agent pods found."
else
  # Counter for agent pod files
  agent_counter=1
  for pod in $agent_pods; do
    if [ -n "$pod" ]; then
      kubectl logs -n kube-system $pod | head -n 10 > agent${agent_counter}.txt
      echo "Saved first 10 lines of $pod logs to agent${agent_counter}.txt"
      agent_counter=$((agent_counter + 1))
    fi
  done
fi

