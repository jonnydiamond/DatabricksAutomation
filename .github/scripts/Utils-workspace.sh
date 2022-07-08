echo "environment variable: $test_TemplateParamFilePath"
echo "environment variable: $test_Location"
echo "environment variable: $test_TemplateFilePath"

#az deployment sub create \
#--location $test_Location \
#--template-file $test_TemplateFilePath \
#--parameters $test_TemplateParamFilePath