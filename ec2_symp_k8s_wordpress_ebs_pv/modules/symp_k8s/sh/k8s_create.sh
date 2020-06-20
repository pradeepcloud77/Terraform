#!/bin/bash

set -e

function error_exit() {
  echo "$1"
  exit 1
}

function write_configfile_and_exit() {
  RESULT=$(curl -s -k -X GET "https://${symp_host}/api/v2/kubernetes/clusters/${K8S_ID}/fetch_kube_config" -H "x-auth-token: $TOKEN" -H "content-type: application/json")
  echo "DEBUG: RESULT = ${RESULT}"

  PUBLICADDRESS=$(jq -r ".public_address" <<< "${RESULT}")
  echo "DEBUG: PUBLICADDRESS = ${PUBLICADDRESS}"
  echo "DEBUG: K8S config file path = ${k8s_confile}"
  KUBECONFIG=$(jq -r ".kubeconfig" <<< "${RESULT}")
  echo "${KUBECONFIG}" | sed "s|https.*6443|$PUBLICADDRESS|g" > "${k8s_confile}"
  echo "End logging"
  exit 0
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
  echo "DEBUG: TOKEN = ${TOKEN}"
  TOKEN=$(curl -s -k -i -H "Content-Type: application/json" -d "${body}" "https://${symp_host}/api/v2/identity/auth" | grep -i x-subject-token | cut -b 18- | tr -d \\r)
  echo "DEBUG: TOKEN = ${TOKEN}"
  if [[ -z "${TOKEN}" ]]; then error_exit "Failed to get token"; fi
}

function get_engine_version_id() {
  echo "DEBUG: k8s_eng = ${k8s_eng}"
  body=$(jq -n \
    --arg engine_version "${k8s_eng}" \
    '{"service_name": "kubernetes-manager", "version_alias": $engine_version}')
  echo "DEBUG: get_engine_version_id body = ${body}"
  ENGINES=$(curl -s -k -X GET "https://${symp_host}/api/v2/engines/versions" -H "x-auth-token: $TOKEN" -d "${body}" -H "Content-Type: application/json")
  echo "DEBUG: ENGINES = ${ENGINES}"

  ENG_ID=$(jq -r --arg eng "${k8s_eng}" '.[] | select(.service_name == "kubernetes-manager" and .family == $eng) | .id' <<< $ENGINES)
  echo "DEBUG: ENG_ID = ${ENG_ID}"
  if [[ -z "${ENG_ID}" ]]; then error_exit "Failed to find engine version"; fi
}

function get_default_storage_pool() {
  STG_ID=$(curl -k -s -X GET "https://${symp_host}/api/v2/storage/pools/default-pool" -H "x-auth-token: $TOKEN" -H 'content-type: application/json' | tr -d '"')
  echo "DEBUG: STG_ID = ${STG_ID}"
  if [[ -z "${STG_ID}" ]]; then error_exit "Failed to get default storage pool"; fi
}

function check_if_exists_k8s_cluster() {
  RESULT=$(curl -s -k -X GET "https://${symp_host}/api/v2/kubernetes/clusters/" -H "x-auth-token: $TOKEN" -H "content-type: application/json")
  echo "DEBUG: RESULT = ${RESULT}"
  FOUND_CLUSTER=$(jq -r --arg kname "${k8s_name}" '.[] | select(.name==$kname)' <<< $RESULT)
  echo "DEBUG: FOUND_CLUSTER = ${FOUND_CLUSTER}"

  if test -z "$FOUND_CLUSTER"
  then
    echo "\$FOUND_CLUSTER is empty"
  else
    echo "\$FOUND_CLUSTER is NOT empty"
    K8S_ID=$(jq -r ".id" <<< "${FOUND_CLUSTER}")
    echo "DEBUG: K8S_ID = ${K8S_ID}"
    wait_for_k8s_active
    write_configfile_and_exit
  fi
}

function create_k8s_cluster() {
  body=$(jq -n \
    --arg name "${k8s_name}" \
    --arg eng_id "${ENG_ID}" \
    --arg net_id "${NET_ID}" \
    --arg pool_id "${STG_ID}" \
    --arg disk_name "${k8s_name}-disk0" \
    --arg disk_size ${k8s_size} \
    --arg node_count ${k8s_count} \
    --arg type "${k8s_type}" \
    --arg fip_id "${FIP_ID}" \
    '{"name":$name,"engine_version_id":$eng_id,"network_id":$net_id,"storage_pool_id":$pool_id,"disks_config":{"disks":[{"name":$disk_name,"disk_size":$disk_size | tonumber}]},"initial_node_count":$node_count | tonumber,"instance_type":$type,"floating_ip_id":$fip_id}')
  echo "DEBUG: create_k8s_cluster body = ${body}"
  RESULT=$(curl -k -s -X POST "https://${symp_host}/api/v2/kubernetes/clusters"  -H "x-auth-token: $TOKEN" -H "content-type: application/json"  -d "${body}")
  echo "DEBUG: RESULT = ${RESULT}"
  RETVAL=$(jq -r ".status" <<< "${RESULT}")
  echo "DEBUG: RETVAL = ${RETVAL}"
  if [[ "${RETVAL}" != "creating" ]]; then
       error_exit "Failed to create cluster"
  fi
  echo "DEBUG: RESULT = ${RESULT}"
  K8S_ID=$(jq -r ".id" <<< "${RESULT}")
  echo "DEBUG: K8S_ID = ${K8S_ID}"
  if [[ -z "${K8S_ID}" ]]; then error_exit "Failed to create k8s cluster"; fi
}

function wait_for_k8s_active() {
  while true; do
  LAST_RESULT=$(curl -s -k -X GET "https://${symp_host}/api/v2/kubernetes/clusters/${K8S_ID}" -H "x-auth-token: $TOKEN" -H "content-type: application/json")
  echo "DEBUG: LAST_RESULT = ${LAST_RESULT}"
  K8S_STATE=$(jq -r ".state" <<< "${LAST_RESULT}")
  echo "DEBUG: CURRENT STATE = ${K8S_STATE}"
  if [[ "${K8S_STATE}" == "running" ]]; then
    echo "DEBUG: Cluster is running"
    break
  elif [[ "${K8S_STATE}" == "error" ]]; then
    echo "DEBUG: Cluster is in error state"
    error_exit "Cluster went into error state"
  else
    echo "Waiting for the K8S to be active.."
    sleep 30
  fi
  done
}

# main()
echo "Start logging"
check_deps
parse_input
get_token
get_default_storage_pool
get_engine_version_id
check_if_exists_k8s_cluster
create_k8s_cluster
wait_for_k8s_active
write_configfile_and_exit
