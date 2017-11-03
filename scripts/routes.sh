#!/bin/bash
sudo su
kubectl get nodes --output=json --output=jsonpath='{range .items[*]}{.status.addresses[?(@.type=="InternalIP")].address},{.spec.podCIDR}{"\n"}{end}' > /tmp/routes
