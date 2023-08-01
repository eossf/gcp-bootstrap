# Script Helper

## SETUP SA
Grant the necessary roles to the Seed Service Account, and enable the necessary API's in the Seed Project. Run it as follows:

./helpers/setup-sa.sh -o <organization id> -p <project id> [-b <billing account id>] [-f <parent folder id>] [-n <service account name>]

In order to execute this script, you must have an account with the following list of permissions:

    resourcemanager.organizations.list
    resourcemanager.projects.list
    billing.accounts.list
    iam.serviceAccounts.create
    iam.serviceAccountKeys.create
    resourcemanager.organizations.setIamPolicy
    resourcemanager.projects.setIamPolicy
    serviceusage.services.enable on the project
    servicemanagement.services.bind on following services:
        cloudresourcemanager.googleapis.com
        cloudbilling.googleapis.com
        iam.googleapis.com
        admin.googleapis.com
        appengine.googleapis.com
    billing.accounts.getIamPolicy on a billing account.
    billing.accounts.setIamPolicy on a billing account.


## LAUNCH WITH ORGANIZATION ID
ORGANIZATION ONLY
./setup_sa.sh -o "xxx" -p "xxx" -b "1234567809" -n "terraform-helper-provision"
or

## LAUNCH WITH FOLDER PARENT ID
ORGANIZATION + FOLDER ENV (for example)
./setup_sa.sh -o "xxx" -f "xxx" -p "project_name_10291" -b "1234567809" -n "terraform-helper-provision"

## RESULT
Verifying organization...
Verifying project...
Verifying billing account...
Skipping project folder verification... (parameter not passed)
Creating Seed Service Account named terraform-helper-provision@project_name_10291.iam.gserviceaccount.com...
Created service account [terraform-helper-provision].
Downloading key to credentials.json...
Skipping grant roles on project folder... (parameter not passed)
Applying permissions for org 32313 and project project_name_10291...
Adding role roles/resourcemanager.organizationViewer...
Adding role roles/resourcemanager.projectCreator...
Adding role roles/billing.user...
Adding role roles/billing.viewer...
Adding role roles/compute.xpnAdmin...
Adding role roles/compute.networkAdmin...
Adding role roles/iam.serviceAccountAdmin...
Adding role roles/resourcemanager.projectIamAdmin...
Enabling APIs...
Operation "operations/acat.p2-854767245524-39d6b1df-ee66-43c8-8a6e-b925aa7ec4e7" finished successfully.
Operation "operations/acat.p2-854767245524-80268bcc-61ab-4c11-a561-e476afd29cb9" finished successfully.
Operation "operations/acat.p2-854767245524-d06ff3b3-7378-46c3-b36e-f0476bfab2c2" finished successfully.
Operation "operations/acat.p2-854767245524-63cfb6ea-c917-4dde-aa45-f65b2994b00e" finished successfully.
Operation "operations/acat.p2-854767245524-5e2382be-1abb-4c66-880f-629937575da5" finished successfully.
Enabling the billing account...
All done.