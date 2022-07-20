echo "environment variable: $param_TemplateParamFilePath"
echo "environment variable: $param_Location"
echo "environment variable: $param_TemplateFilePath"

az deployment sub create \
--location $param_Location \
--template-file $param_TemplateFilePath \
--parameters $param_TemplateParamFilePath
--name "$environment"