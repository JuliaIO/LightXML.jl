xml = """
<CreateQueueResponse>
    <CreateQueueResult>
        <QueueUrl>
            http://queue.amazonaws.com/123456789012/testQueue
        </QueueUrl>
    </CreateQueueResult>
    <ResponseMetadata>
        <RequestId>
            7a62c49f-347e-4fc4-9331-6e8e7a96aa73
        </RequestId>
    </ResponseMetadata>
</CreateQueueResponse>
"""

@test parse_string(xml)["CreateQueueResult"]["QueueUrl"] ==
      "http://queue.amazonaws.com/123456789012/testQueue"


xml = """
<GetUserResponse xmlns="https://iam.amazonaws.com/doc/2010-05-08/">
  <GetUserResult>
    <User>
      <PasswordLastUsed>2015-12-23T22:45:36Z</PasswordLastUsed>
      <Arn>arn:aws:iam::012541411202:root</Arn>
      <UserId>012541411202</UserId>
      <CreateDate>2015-09-15T01:07:23Z</CreateDate>
    </User>
  </GetUserResult>
  <ResponseMetadata>
    <RequestId>837446c9-abaf-11e5-9f63-65ae4344bd73</RequestId>
  </ResponseMetadata>
</GetUserResponse>
"""

@test parse_string(xml)["GetUserResult"]["User"]["Arn"] == "arn:aws:iam::012541411202:root"


xml = """
<GetQueueAttributesResponse>
  <GetQueueAttributesResult>
    <Attribute>
      <Name>ReceiveMessageWaitTimeSeconds</Name>
      <Value>2</Value>
    </Attribute>
    <Attribute>
      <Name>VisibilityTimeout</Name>
      <Value>30</Value>
    </Attribute>
    <Attribute>
      <Name>ApproximateNumberOfMessages</Name>
      <Value>0</Value>
    </Attribute>
    <Attribute>
      <Name>ApproximateNumberOfMessagesNotVisible</Name>
      <Value>0</Value>
    </Attribute>
    <Attribute>
      <Name>CreatedTimestamp</Name>
      <Value>1286771522</Value>
    </Attribute>
    <Attribute>
      <Name>LastModifiedTimestamp</Name>
      <Value>1286771522</Value>
    </Attribute>
    <Attribute>
      <Name>QueueArn</Name>
      <Value>arn:aws:sqs:us-east-1:123456789012:qfoo</Value>
    </Attribute>
    <Attribute>
      <Name>MaximumMessageSize</Name>
      <Value>8192</Value>
    </Attribute>
    <Attribute>
      <Name>MessageRetentionPeriod</Name>
      <Value>345600</Value>
    </Attribute>
  </GetQueueAttributesResult>
  <ResponseMetadata>
    <RequestId>1ea71be5-b5a2-4f9d-b85a-945d8d08cd0b</RequestId>
  </ResponseMetadata>
</GetQueueAttributesResponse>
"""

xml = parse_string(xml)
d = [a["Name"] => a["Value"] for a in xml["GetQueueAttributesResult"]["Attribute"]]

@test d["MessageRetentionPeriod"] == "345600"
@test d["CreatedTimestamp"] == "1286771522"


xml = """
<?xml version="1.0" encoding="UTF-8"?>
<ListAllMyBucketsResult xmlns="http://s3.amazonaws.com/doc/2006-03-01">
  <Owner>
    <ID>bcaf1ffd86f461ca5fb16fd081034f</ID>
    <DisplayName>webfile</DisplayName>
  </Owner>
  <Buckets>
    <Bucket>
      <Name>quotes</Name>
      <CreationDate>2006-02-03T16:45:09.000Z</CreationDate>
    </Bucket>
    <Bucket>
      <Name>samples</Name>
      <CreationDate>2006-02-03T16:41:58.000Z</CreationDate>
    </Bucket>
  </Buckets>
</ListAllMyBucketsResult>
"""

@test [b["Name"] for b in parse_string(xml)["Buckets"]["Bucket"]] == ["quotes", "samples"]


xml = """
<ListDomainsResponse>
  <ListDomainsResult foobar="Hello">
    <DomainName>Domain1</DomainName>
    <DomainName>Domain2</DomainName>
    <NextToken>TWV0ZXJpbmdUZXN0RG9tYWluMS0yMDA3MDYwMTE2NTY=</NextToken>
  </ListDomainsResult>
  <ResponseMetadata>
    <RequestId>eb13162f-1b95-4511-8b12-489b86acfd28</RequestId>
    <BoxUsage>0.0000219907</BoxUsage>
  </ResponseMetadata>
</ListDomainsResponse>
"""

@test parse_string(xml)["ListDomainsResult"][:foobar] == "Hello"
