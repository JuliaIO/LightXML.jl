function xdict(xml)
    for (n,v) in xml_dict(xml; strip_text=true)
        if !isa(n, Symbol)
            return v
        end
    end
end

xml1 = """
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

@test parse_string(xml1)["CreateQueueResult"]["QueueUrl"] ==
      "http://queue.amazonaws.com/123456789012/testQueue"

@test xdict(xml1)["CreateQueueResult"]["QueueUrl"] ==
      "http://queue.amazonaws.com/123456789012/testQueue"



xml2 = """
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

@test parse_string(xml2)["GetUserResult"]["User"]["Arn"] == 
      "arn:aws:iam::012541411202:root"

@test xdict(xml2)["GetUserResult"]["User"]["Arn"] == 
      "arn:aws:iam::012541411202:root"


xml3 = """
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

xml = parse_string(xml3)
d = [a["Name"] => a["Value"] for a in xml["GetQueueAttributesResult"]["Attribute"]]

@test d["MessageRetentionPeriod"] == "345600"
@test d["CreatedTimestamp"] == "1286771522"

xml = xdict(xml3)
d = [a["Name"] => a["Value"] for a in xml["GetQueueAttributesResult"]["Attribute"]]

@test d["MessageRetentionPeriod"] == "345600"
@test d["CreatedTimestamp"] == "1286771522"


xml4 = """
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

@test [b["Name"] for b in parse_string(xml4)["Buckets"]["Bucket"]] == ["quotes", "samples"]

@test [b["Name"] for b in xdict(xml4)["Buckets"]["Bucket"]] == ["quotes", "samples"]

xml5 = """
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

@test parse_string(xml5)["ListDomainsResult"][:foobar] == "Hello"

@test xdict(xml5)["ListDomainsResult"][:foobar] == "Hello"

if Pkg.installed("DataStructures") != nothing


xml6 = """
<?xml version="1.0" encoding="UTF-8"?>
<bookstore brand="amazon">
  <book category="COOKING" tag="first">
    <title lang="en">
        Everyday Italian
    </title>
    <author>Giada De Laurentiis</author>
    <year>2005</year>
    <price>30.00</price>
    <extract copyright="NA">The <b>bold</b> word is <b><i>not</i></b> <i>italic</i>.</extract>
  </book>
  <book category="CHILDREN">
    <title lang="en">Harry Potter</title>
    <author>J K. Rowling</author>
    <year>2005</year>
    <price>29.99</price>
    <foo><![CDATA[<sender>John Smith</sender>]]></foo>
    <extract>Click <a href="foobar.com">right <b>here</b></a> for foobar.</extract>
  </book>
  <metadata>
       <foo>hello!</foo>
  </metadata>
</bookstore>
"""

function normalise_xml(xml)
    o,i,p = readandwrite(
        `bash -c 'xmllint --format --nocdata - | sed s/\ xmlns=\".*\"//g' `)
    write(i, xml)
    close(i)
    readall(o)
end

eval(Expr(:using, :JSON))

for xml in [xml1, xml2, xml3, xml4, xml5, xml6]

    if normalise_xml(xml) != normalise_xml(dict_xml(xml_dict(xml)))

        println(normalise_xml(dict_xml(xml_dict(xml))))


        open(`xargs -0 node -e "var o; o = JSON.parse(process.argv[1]);
                                var u; u = require('util'); 
                                console.log(u.inspect(o, {depth:null, colors: true}));"
              `, "w", STDOUT) do io
            write(io, json(xml_dict(xml)))
        end

        open("/tmp/a", "w") do f write(f, normalise_xml(xml)) end
        open("/tmp/b", "w") do f write(f, normalise_xml(dict_xml(xml_dict(xml)))) end
        run(`opendiff /tmp/a /tmp/b`)
    end


    @test normalise_xml(xml) == normalise_xml(dict_xml(xml_dict(xml)))

end


end #if Pkg.installed("DataStructures") != nothing
