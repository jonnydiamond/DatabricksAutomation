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
- Automated Continuous Deployment 
- Automated package deployment via wheel file creation 
- Logging Framework using the [Opensensus Azure Monitor Exporters](https://github.com/census-instrumentation/opencensus-python/tree/master/contrib/opencensus-ext-azure)
- Support for Databricks Development from VS Code IDE using the [Databricks Connect](https://docs.microsoft.com/en-us/azure/databricks/dev-tools/databricks-connect#visual-studio-code) feature.
- Continuous Development with [Python Local Packaging](https://packaging.python.org/tutorials/packaging-projects/)
- Example Model file which uses the Framework end to end.

---

# Databricks as Infrastructure

There are many ways that a User may create Jobs, Notebooks, upload files to Databricks DBFS, Create Clusters etc. etc. For example, they may interact   with Databricks API/CLI from:
- Local VSCode
- Within Databricks UI 
- Yaml Pipeline on DevOps Agent (Github Actions/Azure DevOps etc.)
 
One issue that arises is the programmatic way for which this approach adopts. It is strong on flexibility, however, it is somewhat weak on governance and reproducibility. 
 
When intereacting with the Databricks API to execute the functionality listed above, we believe that Jobs, Cluster creation etc. come within the realm of "Infrastructure". We must then find a way to enshrine this Infrastructure _as code_ so that it can consistently be redployed in a Continuous Deployment framework as it cascades across environments. 

As such, all Databricks related infrastrucutre will sit within an environment parameter file, alongside all other infrastructure parameters. The Yaml Pipeline will therefore point to this parameters file, and consistently deploy objects listed therein. 

This does not preclude infrastructre creation on ad hoc basis using the API/within the Portal... we in fact provide the development framework to interact with the Databricks API/CLI using a Docker Image in VSCode. Freedom to choose ! 
 
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
  2. ``` az ad sp create-for-rbac -n <InsertNameForServicePrincipal> --role Owner --scopes /subscriptions/<InsertYouSubsriptionID> --sdk-auth ```
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

- Now to update the Parameters File With Amendments Below. Do it for each Environment. Note: You can create as many RBAC Assignments as you want. Simply add a new object to the "RBAC_Assignments" Array and the bash script (run later) will pick it up and create it. 


```json

{
    "dbxSPNAppID": "<>",  # Databricks_API_SP ObjectID Saved In Text File
    "SubscriptionId": "<>", # You SubID

    "RBAC_Assignments": [
        {
            "role":"Key Vault Administrator", 
            "roleBeneficiaryObjID":"3fb6e2d3-7734-43fc-be9e-af8671acf605",  # Your ObjectID Saved In Text File
            "Description": "You Object ID",
            "principalType": "User"
        },
        { 
            "role":"Key Vault Administrator",
            "roleBeneficiaryObjID":"0e3c30b0-dd4e-4937-96ca-3fe88bd8f259",  # Databricks_API_SP ObjectID Saved In Text File
            "Description": "Databricks SPN",
            "principalType": "ServicePrincipal"

        },
        {
            "role":"Contributor", 
            "roleBeneficiaryObjID":"0e3c30b0-dd4e-4937-96ca-3fe88bd8f259",  # Databricks_API_SP ObjectID Saved In Text File
            "Description": "Databricks SPN",
            "principalType": "ServicePrincipal"
        },
        {
            "role":"DBX_Custom_Role", # Custom Role Created In Previous Step
            "roleBeneficiaryObjID":"0e3c30b0-dd4e-4937-96ca-3fe88bd8f259", # Databricks_API_SP ObjectID Saved In Text File
            "Description": "Databricks SPN",
            "principalType": "ServicePrincipal"
        }
    ],
    "Git_Configuration": [
        {
            "git_username": "ciaran28", # Update To Your UserName
            "git_provider": "gitHub"
        }
    ],

}

```

---

# Run The Yaml Pipeline

- In Github you can manually run the pipeline to deploy the evironments to Azure

<img width="1172" alt="image" src="https://user-images.githubusercontent.com/108273509/186510528-29448e4d-1a0e-41b9-a37f-0cd89d226d57.png">

---
---



# Section 1: Docker image load in VS Code

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












)




## Section 4: Create the .env file

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

