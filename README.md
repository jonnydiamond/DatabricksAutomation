![Banner](docs/images/MLOps_for_databricks_Solution_Acclerator_logo.JPG)


- [About This Repository](#About-This-Repository)
- [Details of The Accelerator](#Details-of-The-Accelerator)
- [Databricks as Infrastructure](#Databricks-as-Infrastructure)
- [Create Databricks Custom Role On DBX SPN](#Create-Databricks-Custom-Role-On-DBX-SPN)
- [Create Main Service Principal](#Create-Main-Service-Principal)


# About This Repository

This Repository contains an Azure Databricks development framework for delivering Data Engineering/Machine Learning projects based on the below Azure Technologies:

| Azure Databricks | Azure Log Analytics | Azure Monitor Service  | Azure Key Vault        |
| ---------------- |:-------------------:| ----------------------:| ----------------------:|

---

Azure Databricks is a powerfull technology, used by Data Engineers and Scientists ubiquitously. However, operationalizing it within a fully automated Continuous Integration and Deployment setup may prove challenging. 

The net effect is a disproportionate amount of the Data Scientist/Engineers time contemplating DevOps matters. This Repositories guiding vision is automate as much of the infrastructure as possible. [^1]

---

# Details of The Accelerator

![overview](docs/images/Overview.JPG)
- Creation of four environments
  - Development 
  - UAT
  - PreProduction
  - Production
- Infrastrusture as Code for interacting with Databricks API
- Automated Continuous Deployment 
- Logging Framework using the [Opensensus Azure Monitor Exporters](https://github.com/census-instrumentation/opencensus-python/tree/master/contrib/opencensus-ext-azure)
- Support for Databricks Development from VS Code IDE using the [Databricks Connect](https://docs.microsoft.com/en-us/azure/databricks/dev-tools/databricks-connect#visual-studio-code) feature.
- Continuous Development with [Python Local Packaging](https://packaging.python.org/tutorials/packaging-projects/)
- Example Model file which uses the Framework end to end.

---

# Databricks as Infrastructure

There are many ways that a User may create Jobs, Notebooks, upload files to Databricks DBFS, Create Clusters etc. For example, they may interact   with Databricks API/CLI from:
1. Local VSCode
2. Within Databricks UI 
3. Yaml Pipeline on DevOps Agent (Github Actions/Azure DevOps etc.)
 
The programmatic way for which options 1 & 2 allow us to interact the Databricks API is akin to 'Continuos Development", as opposed to Continuos _Deployment_. It is strong on flexibility, however, it is somewhat weak on governance and reproducibility. 
 
When intereacting with the Databricks API to interact with the Databricks API, we believe that Jobs, Cluster creation etc. should come within the realm of "Infrastructure". We must then find a way to enshrine this Infrastructure _as code_ so that it can consistently be redployed in a Continuous Deployment framework as it cascades across environments. 

As such, all Databricks related infrastrucutre will sit within an environment parameter file [here](#Update-Yaml-Pipeline-Parameters-Files), alongside all other infrastructure parameters. The Yaml Pipeline will therefore point to this parameters file, and consistently deploy objects listed therein, using Bash Steps in the Yaml Pipeline. 

This does not preclude interacting with the Databricks API on ad hoc basis using the "Continuous Development Framework". We in fact provide the Development Framework to do this from a Docker Container in VS Code (Section 2)
 
---

 # Continuous Deployment + Branching Strategy
 
It is hard to talk about Continuos Deployment credibly without addressing the manner in which that Deployment should look... for example... what branching strategy will be adopted?

The Branching Strategy will build out of the box, and is a Trunk Based Branching Strategy. (Go into more detail)

<img width="805" alt="image" src="https://user-images.githubusercontent.com/108273509/186166011-527144d5-ebc1-4869-a0a6-83c5538b4521.png">

-   Feature merge to Main: Deploy to Develop Environment 
-   Merge Request from Main To Release: Deploy to UAT
-   Merge Request Approval from Main to Release: Deploy to PreProduction
-   Tag Release Branch with Stable Version: Deploy to Production 
 

# Pre-requisites
<details close>
<summary>Click Dropdown... </summary>
<br>
  
- Github Account
- Access to an Azure Subscription
- Service Principal With Ownership RBAC permissions assigned. (Instructions below)
- Service Principal with Databricks Custom Role Permissions. (Instructions below)
- VS Code installed.
- Docker Desktop Installed (Instructions below)
  
</details>

---

# Under The Hood
<details close>
<summary>Click Dropdown... </summary>
<br>
  
- Authenticate to Databricks API/CLI using Azure Service Principal Authentication
- Databricks API in Bash
- Databricks CLI in Bash
- Databricks API using Python SDK 
- Yaml Pipelines in Github Actions
- Filter API Responses using JQuery (Bash)
  
</details>

---

# Create Databricks Custom Role On DBX SPN
<details close>
<summary>Click Dropdown... </summary>
<br>
1. Open IAM at Subscription Level and navigate to creating a Custom Role (as shown below)  
<img width="1022" alt="image" src="https://user-images.githubusercontent.com/108273509/186198305-a28acbf2-fe97-4805-b069-a339fb475894.png">
<br>
<br>

2. Provide Cusom Role Name
<img width="527" alt="image" src="https://user-images.githubusercontent.com/108273509/186198849-d8700153-88b8-44f8-886c-147bea3c3280.png">
<br>
<br>
  
3. Provide Databricks Permissions
<img width="1199" alt="image" src="https://user-images.githubusercontent.com/108273509/186199265-9485e474-c21d-4825-b64a-5e33083e60fd.png">

</details>

---

# Create Main Service Principal

Why: You will need to assign RBAC permissions to Azure Resources created on the fly. See JSON document "RBAC_Assignment" secion.

Steps:
  1. Open the Terminal Window in VSCode. Enter:
  2. ```console az ad sp create-for-rbac -n <InsertNameForServicePrincipal> --role Owner --scopes /subscriptions/<InsertYouSubsriptionID> --sdk-auth ```
  3. Do Not Delete Output (required in Next Step) [^4]
  4. Create Github Secret titled "AZURE_CREDENTIALS" and paste output from step 3 [^5] <br>

# Create Databricks SPN

Why: For those who only need permissions to create resources and intereact with the Databricks API.
Steps:
1. Open the Terminal Window in VSCode. Enter: ```console az ad sp create-for-rbac -n <InsertNameForServicePrincipal> --scopes /subscriptions/<InsertYouSubsriptionID> --sdk-auth ``` [^2]
4. Create Github Secrets entitled "ARM_CLIENT_ID", "ARM_CLIENT_SECRET" and "ARM_TENANT_ID". Values are contained within output from step 3 [^3] 
5. In VSCode Terminal Retrieve ApplicationID of Databricks Service Principal by entering (copy to text file): ```az ad sp show --id <insert_SP_ClientID> --query appId -o tsv ```
7. In VSCode Terminal Retrieve ApplicationID of Databricks Service Principal by entering  (copy to text file):  ```az ad sp show --id <insert_SP_ClientID> --query objectId -o tsv ```
9. In VSCode Terminal Retrieve your own ObectID by entering  (copy to text file):  ```az ad user show --id ciaranh@microsoft.com --query objectId ```

# Final Snapshot of Github Secrets

- Secrets in Github should look exactly like this. The secrets are case sensitive, therefore be very cautious when creating. 

<img width="387" alt="image" src="https://user-images.githubusercontent.com/108273509/186392283-01093f5d-9ca2-42cb-8e84-4807920a5f7f.png">

---
# Update Yaml Pipeline Parameters Files

- Now to update the Parameters File With Amendments Below. Do it for each Environment. 
- Parameters File Path: /.github/workflows/Pipeline_Param/
- Note that the databricks specific object parameters align to the JSON syntax that would be required when interacting with the Databricks API.
- The JSON objects are fed to their respective Bash Script, in which the Databricks/API is invoked using a For Loop. Therefore, the JSON parameters file is flexible, allowing us to add and remove objects at will. 
- Important: When assigning RBACs to Users, it would be easier to use alias' instead of objectIDs, for example ciaranh@microsoft.com. In order to use the email accounts etc. you require permissions to use the Graph API, requiring approval from a Global Admin. For simplicity, I have used ObjectId's instead, however, I am cognisant that it is far superior to use alias names.

```json

{
    "dbxSPNAppID": "<>",                      # Databricks_API_SP ObjectID Saved In Text File
    "SubscriptionId": "<>",                   # Enter Your SubID
    

    "Location": "uksouth", 
    "TemplateParamFilePath":"Infrastructure/DBX_CICD_Deployment/Bicep_Params/Development/Bicep.parameters.json",
    "TemplateFilePath":"Infrastructure/DBX_CICD_Deployment/Main_DBX_CICD.bicep",
    "AZURE_DATABRICKS_APP_ID": "2ff814a6-3304-4ab8-85cb-cd0e6f879c1d",
    "MANAGEMENT_RESOURCE_ENDPOINT": "https://management.core.windows.net/",
    "RBAC_Assignments": [           # RBAC Assignments. You Can Add Or Remove As You See Fit. Ingested Into Utils-Assign-RBAC.sh 
        {
            "role":"Key Vault Administrator", 
            "roleBeneficiaryObjID": "<>"        # Your ObjectID Saved In Text File
            "Description": "You Object ID",
            "principalType": "User"
        },
        { 
            "role":"Key Vault Administrator",
            "roleBeneficiaryObjID": "<>"         # Databricks_API_SP ObjectID Saved In Text File
            "Description": "Databricks SPN",
            "principalType": "ServicePrincipal"

        },
        {
            "role":"Contributor", 
            "roleBeneficiaryObjID":  "<>"         # Databricks_API_SP ObjectID Saved In Text File
            "Description": "Databricks SPN",
            "principalType": "ServicePrincipal"
        },
        {
            "role": "DBX_Custom_Role", 
            "roleBeneficiaryObjID":  "<>"         # Databricks_API_SP ObjectID Saved In Text File
            "Description": "Databricks SPN",
            "principalType": "ServicePrincipal"
        }
    ],
    "Clusters": [                       #  Cluster Creation. You Can Add Or Remove As You See Fit. Ingested Into Utils-Create-Cluster.sh 
        {
            "cluster_name": "dbx-sp-cluster",
            "spark_version": "10.4.x-scala2.12",
            "node_type_id": "Standard_D3_v2",
            "spark_conf": {},
            "autotermination_minutes": 30,
            "runtime_engine": "STANDARD",
            "autoscale": {
                "min_workers": 2,
                "max_workers": 4
            }
        },
        {
            "cluster_name": "dbx-sp-cluster2",
            "spark_version": "10.4.x-scala2.12",
            "node_type_id": "Standard_D3_v2",
            "spark_conf": {},
            "autotermination_minutes": 30,
            "runtime_engine": "STANDARD",
            "autoscale": {
                "min_workers": 2,
                "max_workers": 4
            }
        }
    ],
    "WheelFiles": [                        #  Wheel File Creation. You Can Add Or Remove As You See Fit. Ingested Into Utils-Create-Wheels-DBFS-Cluster-Upload.sh
            {
                "setup_py_file_path": "src/pipelines/dbkframework/setup.py",
                "wheel_cluster": "dbx-sp-cluster",
                "upload_to_cluster?": true
            }
    ],
    "Jobs": [                               # To Do
        {
            "name": "job_remote_analysis",
            "settings": {
                "name": "job_remote_analysis",
                "email_notifications": {
                    "no_alert_for_skipped_runs": false
                },
                "max_concurrent_runs": 1,
                "tasks": [
                    {
                        "task_key": "job_remote_analysis",
                        "notebook_task": {
                            "notebook_path": "/Repos/ce79c2ef-170d-4f1c-a706-7814efb94898/DevelopmentFolder/src/tutorial/scripts/framework_testing/remote_analysis",
                            "source": "WORKSPACE"
                        },
                        "cluster_name": "dbx-sp-cluster"
                    }
                ],
                "format": "MULTI_TASK"
            }
        }
    ],
    "Git_Configuration": [                        #  Git Configure Your DBX Env. You Can Add Or Remove As You See Fit. Ingested Into Utils-Create-Repo-Folders.sh
        {
            "git_username": "ciaran28",           # Uppdate With Your Github Username 
            "git_provider": "gitHub"
        }
    ],
    "Repo_Configuration": [                        #  Create Folders in DBX Repos. You Can Add Or Remove As You See Fit. Ingested Into Utils-Create-Repo-Folders.sh
        {
            "url": "https://github.com/ciaran28/DatabricksAutomation",
            "provider": "gitHub",
            "path": "DevelopmentFolder"            # Create Folders As You See Fit. This Example Will Create /Repos/<userfolder>/DevelopmentFolder in DBX Instance
        }
    ]
}


```










---

# Deploy The Azure Environments 

- In Github you can manually run the pipeline to deploy the evironments to Azure

<img width="1172" alt="image" src="https://user-images.githubusercontent.com/108273509/186510528-29448e4d-1a0e-41b9-a37f-0cd89d226d57.png">

---
# Run Python Scripts

- All the Azure Resources will be configured 
  - Repos Git configured with folders created for each environment 
  - Clusters created
  - KeyVault created with PAT Token stored therein 
  - Secret Scopes created with Application Insights Connection string and Service Principal Secrets stored. Given that the Service Principal has RBAC permissions (Key Vault Administrator + Databricks Custom Role+ Contributor), we can use the DBUtils functions _within_ the Databricks Instance to access secrets from KV and intereact with the Databricks API
  - Wheel file creation, whereby .whl files are stored in DBFS, and uploaded to cluster (if boolean set to true in parameters file)
<img width="752" alt="image" src="https://user-images.githubusercontent.com/108273509/186661417-403d58db-147e-4dd5-966a-868876fb2ee0.png">

---
# Section 2: Interact With Databricks From Local VS Code Using Databricks Connect + Docker Image
---

In the previous section, we interacted with Databricks API from the DevOps Agent.

But what if we wish to interact with the Databricks environemnt from our local VS Code? In order to do this we can use "Databricks Connect".

Now... enter Docker. Why are we using this? Configuring the environment set up for Databricks Connect on a Windows machine is a tortuous process, designed to break the will of even the most talented programmer. Instead, we will use a Docker Image the builds a Linux environment, and deals with all of the environment variables and path dependencies out of the box. 

# Steps

![map01](docs/images/map01.png)
1. Clone the Repository : https://github.com/microsoft/dstoolkit-ml-ops-for-databricks/pulls
2. Install Docker Desktop. Visual Code uses the docker image as a remote container to run the solution.
3. Create .env file in the root folder, and keep the file blank for now. (root folder is the parent folder of the project)
4. In the repo, open the workspace. File: workspace.ode-workspace.

> Once you click the file, you will get the "Open Workspace" button at right bottom corner in the code editor. Click it to open the solution into the vscode workspace.

![workspaceselection](docs/images/workspaceselection.jpg)

5. We need to connect to the [docker image as remote container in vs code](https://code.visualstudio.com/docs/remote/attach-container#_attach-to-a-docker-container). In the code repository, we have ./.devcontainer folder that has required docker image file and docker configuration file. Once we load the repo in the vscode, we generally get the prompt. Select "Reopen in Container". Otherwise we can go to the VS code command palette ( ctrl+shift+P in windows), and select the option "Remote-Containers: Rebuild and Reopen in Containers"

![DockerImageLoad](docs/images/DockerImageLoad.jpg)

6. In the background, it is going to build a docker image. We need to wait for sometime to complete build. the docker image will basically contain the a linux environment which has python 3.7 installed. Please have a look at the configuration file(.devcontainer\devcontainer.json) for more details. 
7. Once it is loaded. we will be able to see the python interpreter is loaded successfully. Incase it does not show, we need to load the interpreter manually. To do that, click on the select python interpreter => Entire workspace => /usr/local/bin/python

![pythonversion](docs/images/pythonversion.jpg)

8. You will be prompted with installing the required extension on the right bottom corner. Install the extensions by clicking on the prompts.

![InstallExtensions](docs/images/InstallExtensions.jpg)

9. Once the steps are completed, you should be able to see the python extensions as below:

![pythonversion](docs/images/pythonversion.jpg)


Note: Should you change the .env file, you will need to rebuild the container for those changes to propogate through. 


## Create the .env file

![map04](docs/images/map04.png)

We need to manually change the databricks host and appI_IK values. Other values should be "as is" from the output of the previous script.

- PYTHONPATH: /workspaces/dstoolkit-ml-ops-for-databricks/src/modules [This is  full path to the module folder in the repository.]
- APPI_IK: connection string of the application insight
- DATABRICKS_HOST: The URL of the databricks workspace.
- DATABRICKS_TOKEN: Databricks Personal Access Token which was generated in the previous step.
- DATABRICKS_ORDGID: OrgID of the databricks that can be fetched from the databricks URL.

![DatabricksORGIDandHOSTID](docs/images/DatabricksORGIDandHOSTID.JPG)

Application Insight Connection String

![AppInsightConnectionString](docs/images/AppInsightConnectionString.jpg)

At the end, our .env file is going to look as below. You can copy the content and change the values according to your environment.

``` conf
PYTHONPATH=/workspaces/dstoolkit-ml-ops-for-databricks/src/modules
APPI_IK=InstrumentationKey=e6221ea6xxxxxxf-8a0985a1502f;IngestionEndpoint=https://northeurope-2.in.applicationinsights.azure.com/
DATABRICKS_HOST=https://adb-7936878321001673.13.azuredatabricks.net
DATABRICKS_TOKEN= <Provide the secret>
DATABRICKS_ORDGID=7936878321001673
```

## Section 5: Configure the Databricks connect

![map05](docs/images/map05.png)

1. In this step we are going to configure the databricks connect for VS code to connect to databricks. Run the below command for that from the docker (VS Code) terminal.

``` bash
$ python "src/tutorial/scripts/local_config.py" -c "src/tutorial/cluster_config.json"
```

>Note: If you get any error saying that "ModelNotFound : No module names dbkcore". Try to reload the VS code window and see if you are getting prompt  right bottom corner saying that configuration file changes, rebuild the docker image. Rebuild it and then reload the window. Post that you would not be getting any error. Also, check if the python interpreter is being selected properly. They python interpreter path should be **/usr/local/bin/python **

![Verify_Python_Interpreter](docs/images/Verify_Python_Interpreter.jpg)

### Verify

1. You will be able to see the message All tests passed.

![databricks-connect-pass](docs/images/databricks-connect-pass.jpg)

## Section 6: Wheel creation and workspace upload

![map06](docs/images/map06.png)

In this section, we will create the private python package and upload it to the databricks environment.

1. Run the below command:

``` bash
python src/tutorial/scripts/install_dbkframework.py -c "src/tutorial/cluster_config.json"
```

Post Execution of the script, we will be able to see the module to be installed.

![cluster-upload-wheel](docs/images/cluster-upload-wheel.jpg)

## Section 7: Using the framework

![map07](docs/images/map07.png)

We have a  pipeline that performs the data preparation, unit testing, logging, training of the model.


![PipelineSteps](docs/images/PipelineSteps.JPG)


### Execution from Local VS Code

To check if the framework is working fine or not, let's execute this file : **src/tutorial/scripts/framework_testing/remote_analysis.py** . It is better to execute is using the interactive window. As the Interactive window can show the pandas dataframe which is the output of the script. Otherwise the script can be executed from the Terminal as well.
To run the script from the interactive window, select the whole script => right click => run the selection in the interactive window.

Post running the script, we will be able to see the data in the terminal.

![final](docs/images/final.jpg)

---
---
# Apendix

[^1]: Test
[^2]: <img width="586" alt="image" src="https://user-images.githubusercontent.com/108273509/186402530-ac8b6962-daf9-4f58-a8a0-b7975d953388.png"> <br>
[^3]: <img width="388" alt="image" src="https://user-images.githubusercontent.com/108273509/186403865-6cb2023e-2a44-44ef-b744-c56d232e235a.png"> <br>
[^4]: <img width="690" alt="image" src="https://user-images.githubusercontent.com/108273509/186394172-20896052-6ae2-4063-9179-1950f5b93b3d.png"> <br>
[^5]: <img width="566" alt="image" src="https://user-images.githubusercontent.com/108273509/186401411-37504ae5-1e43-4317-8b11-d14add6d6924.png"> <br>

