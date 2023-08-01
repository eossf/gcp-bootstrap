# Build full GCP platform as code

GCP metairie.dev account is empty at starting, only one project exists "My Project" for testing in GUI

## DONE

Local Installation
- gcloud CLI: [link](https://cloud.google.com/sdk/docs/install?hl=fr)
- terragrunt: [link](https://terragrunt.gruntwork.io/docs/getting-started/install/)

Manually creation
[checklist gcp] ===================================================================

    Enable Cloud Identity and create an organisation
        Set up Cloud Identity, verify your domain and create an organisation

- a FQDN and DNS records (porkbun)
- a Cloud Identity (stephane.metairie@metairie.dev)
- Add roles
    Folder Admin
    Organisation Administrator
    Security Admin
    Service Management Administrator
- an GCP Organisation
- a link to a FQFN (metairie.dev)

[checklist gcp] ===================================================================

    Provision users and groups
        Map your colleagues to Google Cloud

- delegate to external account stephane.metairie@gmail.com (Delegate Organisation Administrator role)
  Add user with email #FIXME I don't see how to do, except from check organisation and click button Add Delegate
on the project by default - bootstrap 
[checklist gcp] ===================================================================

    Assign administrative access
        Ensure that your admin colleagues responsible for setup have the right level of access

- add SA account (terraform-bootstrap) on Project / on Folders , it will impersonate the user with Delegation above
    Add principal stephane.metairie@gmail.com
        with Add role Service Account Token Creator
    Add role Project Billing Manager
    Add Service Usage Admin
- Enable  Cloud Resource Manager API on project bootstrap

[checklist gcp] ===================================================================

    Set up billing
        Select your primary billing account for initial setup

    Configure hierarchy and assign access
        Set up initial folder and project structure, and assign access to colleagues
        Env/Dev

    Configure hierarchy and assign access
        Set up initial folder and project structure, and assign access to colleagues
- Add Env/Dev

## TODO

- [checklist gcp] ===================================================================

    Set up networking
        Set up your initial networks

    Centralise logging
        Configure and centralise logs

    Enable monitoring
        Set up initial monitoring

    Enable security capabilities
        Set up organisational policies and learn more about Google Cloud's security offerings

    Choose a support model 

## References
A Hitchhiker’s Guide to GCP Service Account Impersonation in Terraform



## Provision
### Connection

````
# connect with delegated account (use SA terraform-bootstrap)
gcloud auth application-default login

# add default project to quota 
gcloud auth application-default set-quota-project "inlaid-stack-394220"
````


