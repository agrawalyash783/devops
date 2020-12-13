About :
1.This Terraform code is to trigger lambda function whenever CSV file get uploads in S3 bucket and insert that record into dynamoDB.
2.This code also create API gateway with POST,GET,DELETE method to perform CRUD operations on dynamoDB.
3.To perform CRUD operations I have used lambda functions with different platform such as python and nodeJS.
4.POST lambda function will use to perform put and update opetaions.
  to test lambda function create event and enter the JSON format in body
    {
      "id":"55",
      "name":"XYZ",
      "age":"54",
      "city":"qwe"
    }
5.GET function will use to scan and get items from table
6.DELETE function will use to delete item with key ID.
  to test lambda function create event and enter the JSON format in body
  {
  "pathParameters": {
    "id": "55"
  }
}



Instruction to run this code:

1. Clone all the files in your working directory.
- git clone https://github.com/agrawalyash783/devops.git
2. Make sure you have terraform.exe file in your working directory.
3. check terraform version by terraform -version command in CLI.
4. Enter your access key,secret access key, region and account ID in main.tf
5. The terraform init command is used to initialize a working directory containing Terraform configuration files. This is the first command that should be run after writing a new Terraform configuration or cloning an existing one from version control.
6. Enter command terraform plan to check execution plan.
7. Finally to apply the execution plan, Enter terraform apply.
8. Once you done with it go to s3 bucket and upload employee.csv file.
9. Once file get uploads you will see that lambda function gets trigger and data gets inserted in dynamoDB table
10. you can perform CRUD operations on dynamoDB by API URL.
11. User need to have postman to test or perform operations through API.
12. If you see Error: Internal server error. Please check you have appropriate permissions to perform task.

References:
NodeJS code -https://medium.com/avmconsulting-blog/

