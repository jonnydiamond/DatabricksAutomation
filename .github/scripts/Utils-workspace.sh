echo "What is going on???"

echo "environment variable: $test_TemplateParamFilePath"

echo $test_TemplateParamFilePath

echo 'templateFilePath : $TemplateParamFilePath'

az deployment sub create \
--location $Location \
--template-file $TemplateFilePath \
--parameters $TemplateParamFilePath