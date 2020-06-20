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
  NET_ID=$(echo ${k8s_subnet:7:8}-${k8s_subnet:15:4}-${k8s_subnet:19:4}-${k8s_subnet:23:4}-${k8s_subnet:27:12})
  echo "DEBUG: NET_ID = ${NET_ID}"
  FIP_ID=$(echo ${k8s_eip:9:8}-${k8s_eip:17:4}-${k8s_eip:21:4}-${k8s_eip:25:4}-${k8s_eip:29:12})
  echo "DEBUG: FIP_ID = ${FIP_ID}"
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

function delete_k8s_cluster() {
  RESULT=$(curl -k -s -X DELETE "https://${symp_host}/api/v2/kubernetes/clusters/${K8S_ID}"  -H "x-auth-token: $TOKEN" -H "content-type: application/json"  -d "${body}")
  echo "DEBUG: RESULT = ${RESULT}"
}

function wait_for_k8s_deletion() {
  while true; do
  check_if_exists_k8s_cluster
  LAST_RESULT=$(curl -s -k -X GET "https://${symp_host}/api/v2/kubernetes/clusters/${K8S_ID}" -H "x-auth-token: $TOKEN" -H "content-type: application/json")
  echo "DEBUG: LAST_RESULT = ${LAST_RESULT}"
  K8S_STATE=$(jq -r ".state" <<< "${LAST_RESULT}")
  if [[ "${K8S_STATE}" == "error" ]]; then
    echo "DEBUG: Cluster is in error state"
    error_exit "Cluster went into error state"
  else
    echo "Waiting for the K8S to be deleted.."
    sleep 15
  fi
  done
}

# main()
echo "Start logging"
check_deps
parse_input
get_token
check_if_exists_k8s_cluster
delete_k8s_cluster
wait_for_k8s_deletion
echo "End logging"
