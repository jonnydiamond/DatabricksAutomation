# The Script Will Ingest Parameters File In Order To Determine Location Of Setup.py Files.
# Each Setup.py Relates To The Creation Of A New Wheel File, Which Will Be Saved In 
# DBFS In A Folder Corresponding To The Cluster The Wheel File Is To Be Uploaded To. 


# TO DO : MUST MAKE THE WHEEL FILES DYNAMIC

echo "Import Wheel Dependencies"
python -m pip install --upgrade pip
python -m pip install flake8 pytest pyspark pytest-cov requests
pip3 install -r ./src/pipelines/dbkframework/requirements.txt
python -m pip install --user --upgrade setuptools wheel
sudo apt-get install pandoc


echo "Ingest JSON Environment File"
JSON=$( jq '.' .github/workflows/Pipeline_Param/$environment.json)
echo "${JSON}" | jq


for row in $(echo "${JSON}" | jq -r '.WheelFiles[] | @base64'); do
    _jq() {
        echo ${row} | base64 --decode | jq -r ${1}
    }

    wheel_cluster=$(_jq '.wheel_cluster')
    setup_py_file_path=$(_jq '.setup_py_file_path')
    # We Are Removing Setup.py From The FilePath 'setup_py_file_path'
    root_dir_file_path=${setup_py_file_path%/*}
    
    echo "Wheel File Destined For Cluster: $wheel_cluster "
    echo "Location Of Setup.py File For Wheel File Creation; $setup_py_file_path"
    
    cd src/pipelines/dbkframework
    # Create The Wheel File
    python setup.py sdist bdist_wheel
    
    cd dist 
    ls
    wheel_file_name=$( ls -d -- *.whl )
    echo "Wheel File Name: $wheel_file_name"

    # Install Wheel File
    echo "$root_dir_file_path/dist/$wheel_file_name"
    pip uninstall -y $wheel_file_name
    pip install $wheel_file_name

    # Upoload Wheel File To DBFS Folder. Wheel File Will Be Stored In A Folder Relating To The Cluster
    # It Is To Be Deployed To

    databricks fs rm dbfs:/FileStore/dev/$wheel_file_name
    echo "$root_dir_file_path/dist/$wheel_file_name"
    echo "dbfs:/FileStore/dev/$wheel_file_name"
    databricks fs cp $wheel_file_name dbfs:/FileStore/dev/$wheel_file_name --overwrite
    databricks fs ls



    # Remove dist folder from DevOps Agent
    #ls
    #cd ..
    #ls
    #rm -rf dist
    #pip uninstall -y $wheel_file_name

    



done