#!/bin/bash

set -e

function error_exit() {
  echo "$1"
  exit 1
}

function check_deps() {
  test -f $(which jq) || error_exit "jq command not detected in path, please install it"
  test -f $(which curl) || error_exit "curl command not detected in path, please install it"
}

function parse_input() {
  eval "$(jq -r '@sh "export HOST=\(.host) DOMAIN=\(.domain) USER=\(.user) PASSWORD=\(.password) PRJID=\(.project_id) KNAME=\(.name)"')"
}

function get_token() {
  eval pass_new=${PASSWORD}
  echo "DEBUG: pass_new = ${pass_new}" >>k8s_info.log
  echo "DEBUG: HOST = ${HOST}" >>k8s_info.log
  echo "DEBUG: USER = ${USER}" >>k8s_info.log
  echo "DEBUG: DOMAIN = ${DOMAIN}" >>k8s_info.log
  echo "DEBUG: PRJID = ${PRJID}" >>k8s_info.log
  body=$(jq -n \
    --arg domain "${DOMAIN}" \
    --arg user "${USER}" \
    --arg password "${pass_new}" \
    --arg project "${PRJID}" \
    '{"auth":{"identity":{"methods":["password"],"password":{"user":{"name":$user,"password":$password,"domain":{"name":$domain}}}},"scope":{"project":{"name":$project,"domain":{"name":$domain}}}}}')
  echo "DEBUG: get_token body = ${body}" >>k8s_info.log
  TOKEN=$(curl -s -k -i -H "Content-Type: application/json" -d "${body}" "https://${HOST}/api/v2/identity/auth" | grep -i x-subject-token | cut -b 18- | tr -d \\r)
  echo "DEBUG: TOKEN = ${TOKEN}" >>k8s_info.log
  if [[ -z "${TOKEN}" ]]; then error_exit "Failed to get token"; fi
}

function check_if_exists_k8s_cluster() {
  RESULT=$(curl -s -k -X GET "https://${HOST}/api/v2/kubernetes/clusters/" -H "x-auth-token: $TOKEN" -H "content-type: application/json")
  echo "DEBUG: RESULT = ${RESULT}" >>k8s_info.log
  FOUND_CLUSTER=$(jq -r --arg kname "${KNAME}" '.[] | select(.name==$kname)' <<< $RESULT)
  echo "DEBUG: FOUND_CLUSTER = ${FOUND_CLUSTER}" >>k8s_info.log

  if test -z "$FOUND_CLUSTER"
  then
    error_exit "Cluster with this name not found!"
  else
    echo "Cluster found" >>k8s_info.log
  fi
}

function produce_json_output() {
  jq '{nodes_id:[.status.nodes_status | .[].node_id] | join(","),nodes_ipv4:[.status.nodes_status | .[].internal_address] | join(","),storage_pool_id:.storage_pool_id,cluster_id:.id,security_groups:.security_groups.node,fip_id:.floating_ip_id,project_id:.project_id,net_id:.network_id,instance_type:.instance_type,initial_node_count:.initial_node_count| tostring }' <<< "${FOUND_CLUSTER}"
}

# main()
echo "Start logging" >k8s_info.log
check_deps
parse_input
get_token
check_if_exists_k8s_cluster
produce_json_output
echo "End logging" >>k8s_info.log
