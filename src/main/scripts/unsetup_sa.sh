#!/bin/bash
# Copyright 2018 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


set -e
set -u

o=""
p=""
b=""
f=""
n=""

usage() {
  echo
  echo " Usage:"
  echo "     $0 -o <organization id> -p <project id> [-b <billing account id>] [-f <parent folder id>] [-n <service account name>]"
  echo "         organization id        (required)"
  echo "         project id             (required)"
  echo "         billing account id     (optional)"
  echo "         parent folder id       (optional)"
  echo "         service account name   (optional)"
  echo
  echo " The billing account id is required if owned by a different organization"
  echo " than the Seed Project organization."
  echo
  exit 1
}

# Check for input variables
while getopts ":ho:p:b:f:n:" OPT; do
  # shellcheck disable=SC2213
  case ${OPT} in
    o )
      o=$OPTARG
      ;;
    p )
      p=$OPTARG
      ;;
    b )
      b=$OPTARG
      ;;
    f )
      f=$OPTARG
      ;;
    n )
      n=$OPTARG
      ;;
    : )
      echo
      echo " Error: option -${OPTARG} requires an argument"
      usage
      ;;
   \? )
      echo
      echo " Error: invalid option -${OPTARG}"
      usage
      ;;
  esac
done
shift $((OPTIND -1))

# Check for required input variables
if [ -z "${o}" ] || [ -z "${p}" ]; then
  echo
  echo " Error: -o <organization id> and -p <project id> required."
  usage
fi

# Organization ID
echo "Verifying organization..."
ORG_ID="$(gcloud organizations list --format="value(ID)" --filter="$o")"

if [[ $ORG_ID == "" ]]; then
  echo "The organization id provided does not exist. Exiting."
  exit 1;
fi

# Seed Project
echo "Verifying project..."
SEED_PROJECT="$(gcloud projects describe --format="value(projectId)" "$p")"

if [[ $SEED_PROJECT == "" ]]; then
  echo "The Seed Project does not exist. Exiting."
  exit 1;
fi

# Billing account
if [ -z "${b}" ]; then
  echo "Skipping billing account verification... (parameter not passed)"
else
  echo "Verifying billing account..."
  BILLING_ACCOUNT="$(gcloud beta billing accounts list --format="value(ACCOUNT_ID)" --filter="$b")"

  if [[ $BILLING_ACCOUNT == "" ]]; then
    echo "The billing account does not exist. Exiting."
    exit 1;
  fi
fi

# Project parent folder
if [ -z "${f}" ]; then
  echo "Skipping project parent folder verification... (parameter not passed)"
  PARENT_FOLDER_ID=""
else
  echo "Verifying project folder..."
  PARENT_FOLDER_ID="$(gcloud resource-manager folders list --format="value(ID)" --folder="$f")"

  if [[ $PARENT_FOLDER_ID == "" ]]; then
    echo "The project parent folder does not exist. Exiting."
    exit 1;
  fi
fi

# ---------------------------------------------------------------------

# Seed Service Account deletion
if [ -z "${n}" ]; then
    SA_NAME="project-factory-${RANDOM}"
else
    SA_NAME="$n"
fi
SA_ID="${SA_NAME}@${SEED_PROJECT}.iam.gserviceaccount.com"

# disable the billing account
if [[ ${BILLING_ACCOUNT:-} != "" ]]; then
  echo "Disabling the billing account..."
  gcloud beta billing accounts remove-iam-policy-binding "$BILLING_ACCOUNT" \
    --member="serviceAccount:${SA_ID}" \
    --role="roles/billing.user"
fi

# Disable required API's
echo "Disabling APIs..."
gcloud services disable \
  cloudresourcemanager.googleapis.com \
  --project "${SEED_PROJECT}"

gcloud services disable \
  cloudbilling.googleapis.com \
  --project "${SEED_PROJECT}"

gcloud services disable \
  billingbudgets.googleapis.com \
  --project "${SEED_PROJECT}"

gcloud services disable \
  iam.googleapis.com \
  --project "${SEED_PROJECT}"

gcloud services disable \
  admin.googleapis.com \
  --project "${SEED_PROJECT}"

gcloud services disable \
  appengine.googleapis.com \
  --project "${SEED_PROJECT}"

# Remove roles/resourcemanager.projectCreator to the service account on the organization
echo "Removing role roles/resourcemanager.projectCreator..."
gcloud organizations remove-iam-policy-binding \
  "${ORG_ID}" \
  --member="serviceAccount:${SA_ID}" \
  --role="roles/resourcemanager.projectCreator"

# Remove roles/billing.user to the service account on the organization
echo "Removing role roles/billing.user..."
gcloud organizations remove-iam-policy-binding \
  "${ORG_ID}" \
  --member="serviceAccount:${SA_ID}" \
  --role="roles/billing.user"

# Remove roles/billing.viewer to the service account on the organization
echo "Removing role roles/billing.viewer..."
gcloud organizations remove-iam-policy-binding \
  "${ORG_ID}" \
  --member="serviceAccount:${SA_ID}" \
  --role="roles/billing.viewer"

# Remove roles/compute.xpnAdmin to the service account on the organization
echo "Removing role roles/compute.xpnAdmin..."
gcloud organizations remove-iam-policy-binding \
  "${ORG_ID}" \
  --member="serviceAccount:${SA_ID}" \
  --role="roles/compute.xpnAdmin"

# Remove roles/compute.networkAdmin to the service account on the organization
echo "Removing role roles/compute.networkAdmin..."
gcloud organizations remove-iam-policy-binding \
  "${ORG_ID}" \
  --member="serviceAccount:${SA_ID}" \
  --role="roles/compute.networkAdmin"

# Remove roles/iam.serviceAccountAdmin to the service account on the organization
echo "Removing role roles/iam.serviceAccountAdmin..."
gcloud organizations remove-iam-policy-binding \
  "${ORG_ID}" \
  --member="serviceAccount:${SA_ID}" \
  --role="roles/iam.serviceAccountAdmin"

# Remove roles/resourcemanager.projectIamAdmin to the Seed Service Account on the Seed Project
echo "Removing role roles/resourcemanager.projectIamAdmin..."
gcloud projects remove-iam-policy-binding \
  "${SEED_PROJECT}" \
  --member="serviceAccount:${SA_ID}" \
  --role="roles/resourcemanager.projectIamAdmin"

echo "Interrupting permissions for org $ORG_ID and project $SEED_PROJECT..."
# Remove roles/resourcemanager.organizationViewer to the Seed Service Account on the organization
echo "Removing role roles/resourcemanager.organizationViewer..."
gcloud organizations remove-iam-policy-binding \
  "${ORG_ID}" \
  --member="serviceAccount:${SA_ID}" \
  --role="roles/resourcemanager.organizationViewer"

if [[ $PARENT_FOLDER_ID == "" ]]; then
  echo "Skipping Remove roles on project parent folder... (parameter not passed)"
else
  echo "Interrupting permissions for parent folder $PARENT_FOLDER_ID..."
  # Remove roles/resourcemanager.folderViewer to the Seed Service Account on the parent folder
  echo "Removing role roles/resourcemanager.folderViewer..."
  gcloud resource-manager folders remove-iam-policy-binding \
    "${PARENT_FOLDER_ID}" \
    --member="serviceAccount:${SA_ID}" \
    --role="roles/resourcemanager.folderViewer"
fi

echo "Destroying Seed Service Account named $SA_ID..."
# Destroy SA
gcloud iam service-accounts delete "${SA_ID}" --quiet

echo "All done."
