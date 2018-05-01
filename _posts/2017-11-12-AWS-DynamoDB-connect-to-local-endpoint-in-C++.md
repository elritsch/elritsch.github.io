---
title: Connect to local Amazon AWS DynamoDB endpoint using AWS C++ SDK
layout: default
comments: true
tags:
 - AWS
 - DynamoDB
 - C++
---

Start local DynamoDB service
----------------------------
1. Download and unzip the `DynamoDBLocal.jar` file from the [AWS DynamoDB download page](https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/DynamoDBLocal.html#DynamoDBLocal.DownloadingAndRunning).

1. Start a local DynamoDB service (on the default port `8000`):
```shell
$ java -Djava.library.path=./DynamoDBLocal_lib -jar DynamoDBLocal.jar -shared
```

Connect to local DynamoDB service in a C++ program
--------------------------------------------------

* Get the AWS C++ SDK from [the GitHub project page](https://github.com/aws/aws-sdk-cpp). Instructions on how to compile the code are provided on said page.

* Put this C++ code to access the local DynamoDB endpoint in a new C++ source file:

    ```c++
    #include <aws/core/Aws.h>
    #include <aws/core/utils/Outcome.h>
    #include <aws/dynamodb/DynamoDBClient.h>
    #include <aws/dynamodb/model/CreateTableRequest.h>
    #include <aws/dynamodb/model/ListTablesRequest.h>


    int main() {
        Aws::SDKOptions options;
        Aws::InitAPI(options);

        const Aws::String table = "my_test_table_new";

        Aws::Client::ClientConfiguration clientConfig;
        clientConfig.scheme = Aws::Http::Scheme::HTTP;
        clientConfig.endpointOverride = "localhost:8000";
        Aws::DynamoDB::DynamoDBClient dynamoClient(clientConfig);

        std::cout << "Listing tables..." << std::endl;
        Aws::DynamoDB::Model::ListTablesRequest listTablesRequest;
        const auto &listTablesOutcome = dynamoClient.ListTables(listTablesRequest);

        if (listTablesOutcome.IsSuccess()) {
            std::cout << "Found the following DynamoDB tables: ";
            const auto &allTables = listTablesOutcome.GetResult().GetTableNames();
            for (const auto &table: allTables) {
                std::cout << table << " ";
            }
        } else {
            std::cout << "Failed to list table: " <<
                      listTablesOutcome.GetError().GetMessage() << std::endl;
        }

        Aws::ShutdownAPI(options);
        return 0;
    }
    ```

* Note: To compile the above code, make sure you configure the compiler and linker in the following way:
  * Add the directories `aws-cpp-sdk-core/include` and `aws-cpp-sdk-dynamodb/include` to the compiler include path. These directories are part of the source repository of the AWS SDK.
  * Link the binary to the dynamically linked libraries `aws-cpp-sdk-core/libaws-cpp-sdk-core.dylib` and `aws-cpp-sdk-dynamodb/libaws-cpp-sdk-dynamodb.dylib`  (this is on macOS, on Unix-like systems the files will end in `.so` rather than `.dylib`). The files are build results of the AWS SDK and will therefore appear either in the AWS SDK build directory or the AWS SDK install directory (if you installed the AWS SDK on your system).
