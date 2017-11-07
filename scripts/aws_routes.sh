#!/bin/bash
ROUTE_TABLE_ID=$1

aws ec2 describe-route-tables --route-table-id "${ROUTE_TABLE_ID}" --filters "Name=route.state,Values=blackhole" --query 'RouteTables[0].Routes[?State == `blackhole`]' | jq -r ".[].DestinationCidrBlock" | while read cidr ; do
  aws ec2 delete-route --route-table-id "${ROUTE_TABLE_ID}" --destination-cidr-block "$cidr"
done

cat tmp/routes | tr " " "\n" |  while read item ; do
  IP=$(echo $item | cut -d ',' -f 1)
  CIDR=$(echo $item | cut -d ',' -f 2)
  NETWORK_INTERFACE=$(aws ec2 describe-instances --filters "Name=private-ip-address,Values=$IP" --query 'Reservations[0].Instances[0].NetworkInterfaces[0].NetworkInterfaceId' --output text)
  echo "$NETWORK_INTERFACE - $IP - $CIDR"
  aws ec2 create-route --route-table-id "${ROUTE_TABLE_ID}" --network-interface-id $NETWORK_INTERFACE --destination-cidr-block "$CIDR"
done
