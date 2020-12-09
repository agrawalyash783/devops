import boto3
s3_client = boto3.client("s3")

dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table('ScaleRealAssignment')

def lambda_handler(event, context):
    bucket_name = event['Records'][0]['s3']['bucket']['name']
    s3_file_name = event['Records'][0]['s3']['object']['key']
    resp = s3_client.get_object(Bucket=bucket_name,Key=s3_file_name)
    data= resp['Body'].read().decode('utf-8')
    project = data.split("\n")
    for n in project:
        print(n)
        n_data = n.split(",")
        # Adding data to dynamoDB
        try:
            table.put_item(
                Item= {
                "name": n_data[0],
                "age": n_data[1],
                "number": n_data[2],
                "city": n_data[3]
            })
        except Exception as e:
            print("End of file")