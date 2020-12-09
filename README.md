Instruction to run this code:

1. User must configure with AWS CLI
2. User must have terraform in system
3. User will have to run command AWS configure in CLI and Enter Access key and secret access key of aws-user
4. User will have to git clone the data and run the following commands 
5. terraform init
6. terraform plan
7. terraform apply
8. If user get an error 
Error putting object in S3 bucket (scalerealassignment): NoSuchBucket: The specified bucket does not exist
        status code: 404, request id: 1E399B6DCB9159F0, host id: lBMwlr8qYb6GE14GFlW6XBeKcBfQihcjMufU4h4V36qboXo9RNbVH4xq4HALtdVYNQ9ZnJfiFlA=
9. Reply use terraform apply command as many times it take time to create S3 bucket and hence file didnt get upload in bucket
