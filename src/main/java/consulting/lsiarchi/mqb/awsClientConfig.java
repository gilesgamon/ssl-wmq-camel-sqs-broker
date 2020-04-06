package consulting.lsiarchi.mqb;

import com.amazonaws.ClientConfiguration;
import com.amazonaws.Protocol;
import com.amazonaws.auth.AWSCredentials;
import com.amazonaws.auth.AWSCredentialsProvider;
import com.amazonaws.auth.BasicSessionCredentials;
import com.amazonaws.auth.AWSStaticCredentialsProvider;

import com.amazonaws.http.TlsKeyManagersProvider;
import com.amazonaws.http.NoneTlsKeyManagersProvider;

import com.amazonaws.client.builder.AwsClientBuilder;
import com.amazonaws.services.sqs.AmazonSQS;
import com.amazonaws.services.sqs.AmazonSQSClient;
import com.amazonaws.services.sqs.AmazonSQSClientBuilder;

import javax.net.ssl.KeyManager;
import javax.net.ssl.KeyManagerFactory;

// This module is needed because (it seems) camel have hard coded a default SunX509 instead of getDefault()
// IBM's Java doesn't support SunX509 - and I've spilt too much of my own blood trying to get MQ working
// on Sun's Java to want to revert to that

public class awsClientConfig {

  private String region = null;
  private String keystore = null;
  private String algorithm = null;
  private String accessKey = null;
  private String secretKey = null;
  private String token = null;
  private String keystoreType = "";
  private String keystorePassword = "";
  private String keystoreProvider = "IBMJCE";
  private TlsKeyManagersProvider keyManagers = null;

  private AmazonSQSClient AmazonSQSClient = null;

  public AWSCredentialsProvider createCredentialsProvider(String accessKey, String secretKey, String token) {

    AWSCredentials credentials = new BasicSessionCredentials(accessKey, secretKey, token);
    AWSCredentialsProvider credentialsProvider = new AWSStaticCredentialsProvider(credentials);

    return credentialsProvider;
  }

  public ClientConfiguration createClientConfig() {
    TlsKeyManagersProvider tlsKeyManagersProvider = NoneTlsKeyManagersProvider.getInstance();
    ClientConfiguration clientConfiguration = null;
    boolean isClientConfigFound = false;

    final String protocol = "https"; 

    if (protocol.equals("https")) {
        System.out.println("Configuring AWS-SQS for HTTPS protocol");
        if (isClientConfigFound) {
            clientConfiguration = clientConfiguration.withProtocol(Protocol.HTTPS).withTlsKeyManagersProvider(tlsKeyManagersProvider);
        } else {
            clientConfiguration = new ClientConfiguration().withProtocol(Protocol.HTTPS).withTlsKeyManagersProvider(tlsKeyManagersProvider);
            isClientConfigFound = true;
        }
    }

    return clientConfiguration;
  }
}
