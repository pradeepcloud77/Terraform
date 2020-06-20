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

function get_token() {
  eval symp_pass_new=${symp_password}
  echo "DEBUG: symp_pass_new = ${symp_pass_new}"
  echo "DEBUG: symp_host = ${symp_host}"
  echo "DEBUG: symp_user = ${symp_user}"
  echo "DEBUG: symp_domain = ${symp_domain}"
  echo "DEBUG: symp_prj = ${symp_prj}"
  body=$(jq -n \
    --arg domain "${symp_domain}" \
    --arg user "${symp_user}" \
    --arg password "${symp_pass_new}" \
    --arg project "${symp_prj}" \
    '{"auth":{"identity":{"methods":["password"],"password":{"user":{"name":$user,"password":$password,"domain":{"name":$domain}}}},"scope":{"project":{"name":$project,"domain":{"name":$domain}}}}}')
  echo "DEBUG: get_token body = ${body}"
  TOKEN=$(curl -s -k -i -H "Content-Type: application/json" -d "${body}" "https://${symp_host}/api/v2/identity/auth" | grep -i x-subject-token | cut -b 18- | tr -d \\r)
  echo "DEBUG: TOKEN = ${TOKEN}"
  if [[ -z "${TOKEN}" ]]; then error_exit "Failed to get token"; fi
}

function check_if_exists_k8s_cluster() {
  RESULT=$(curl -s -k -X GET "https://${symp_host}/api/v2/kubernetes/clusters/" -H "x-auth-token: $TOKEN" -H "content-type: application/json")
  echo "DEBUG: RESULT = ${RESULT}"
  FOUND_CLUSTER=$(jq --arg kname "${k8s_name}" '.[] | select(.name==$kname)' <<< "${RESULT}")
  echo "DEBUG: FOUND_CLUSTER = ${FOUND_CLUSTER}"

  if test -z "$FOUND_CLUSTER"
  then
    echo "Cluster is already deleted"
    exit 0
  else
    echo "Cluster found"
    K8S_ID=$(jq -r ".id" <<< "${FOUND_CLUSTER}")
    echo "DEBUG: K8S_ID = ${K8S_ID}"
  fi

  K8S_ID=$(jq -r '.id' <<< "${FOUND_CLUSTER}")
  echo "DEBUG: K8S_ID = ${K8S_ID}"
}

function add_private_registry() {
  body=$(jq -n \
    --arg prv_reg "${k8s_prv_reg}" \
    '{"address": $prv_reg}')
    RESULT=$(curl -k -s -X PUT "https://${symp_host}/api/v2/kubernetes/clusters/${K8S_ID}/private_registry"  -H "x-auth-token: $TOKEN" -H "content-type: application/json"  -d "${body}")
  echo "DEBUG: RESULT = ${RESULT}"
  REGISTRY_ID=$(jq -r '.id' <<< "${RESULT}")
  echo "DEBUG: REGISTRY_ID = ${REGISTRY_ID}"
}

function wait_for_registry_configured() {
  while true; do
  LAST_RESULT=$(curl -s -k -X GET "https://${symp_host}/api/v2/kubernetes/clusters/${K8S_ID}/registries" -H "x-auth-token: $TOKEN" -H "content-type: application/json")
  echo "DEBUG: LAST_RESULT = ${LAST_RESULT}"
  FOUND_REGISTRY=$(jq --arg regid "${REGISTRY_ID}" '.[] | select(.id==$regid)' <<< "${LAST_RESULT}")
  echo "DEBUG: FOUND_REGISTRY = ${FOUND_REGISTRY}"
  REGISTRY_STATE=$(jq -r ".registry_state" <<< "${FOUND_REGISTRY}")
  if [[ "${REGISTRY_STATE}" == "configured" ]]; then
    echo "DEBUG: Registry is in configured state"
    exit 0
  else
    echo "Waiting for the registry to be configured.."
    sleep 5
  fi
  done
}

# main()
echo "Start logging"
check_deps
get_token
check_if_exists_k8s_cluster
add_private_registry
wait_for_registry_configured
echo "End logging"
