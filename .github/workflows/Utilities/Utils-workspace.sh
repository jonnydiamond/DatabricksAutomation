echo "What is going on???"

echo 'templateFilePath : $TemplateParamFilePath'

az deployment sub create \
--location $Location \
--template-file $TemplateFilePath \
--parameters $TemplateParamFilePath