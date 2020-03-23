package consulting.lsiarchi.mqb;

import java.io.FileInputStream;
import java.security.KeyStore;
import java.security.SecureRandom;

import javax.net.ssl.KeyManagerFactory;
import javax.net.ssl.SSLContext;
import javax.net.ssl.SSLSocketFactory;
import javax.net.ssl.TrustManagerFactory;

// This is all a bit messy - some redundent code in here to tidy

public class SSLConfiguration {

  private String keystore = null;
  private String keystorePassword = "";
  private String keystoreProvider = "SUN";
  private String truststoreProvider = "SUN";
  private String truststore = null;
  private String keystoreType = "";
  private String truststorePassword = "";
  private String certAlias = "client";
  private String useIBMCipherMappings = "false";
  private String cipherSuite;
  private String protocols = "TLSv1.2";
  private SSLSocketFactory SSLSocketFactory = null;

  public SSLSocketFactory createSSLSocketFactory(String keyStorePath, String trustStorePath, char[] keystorePassword, char[] truststorePassword, char[] keyManagerPassword)
      throws Exception {

    System.out.println("createSSLSocketFactory");
    KeyManagerFactory keyManagerFactory = null;
    if (keyStorePath != null) {

      // Create a keystore object for the keystore
      KeyStore keyStore = KeyStore.getInstance("JKS");

      // Open our file and read the keystore
      try (FileInputStream keyStoreInput = new FileInputStream(keyStorePath)) {
        keyStore.load(keyStoreInput, keystorePassword);
      }

      // Build key manager factory
      keyManagerFactory = KeyManagerFactory.getInstance(KeyManagerFactory.getDefaultAlgorithm());
      keyManagerFactory.init(keyStore, keyManagerPassword);
    }

    TrustManagerFactory trustManagerFactory = null;
    if (trustStorePath != null) {
      // Create a keystore object for the truststore
      KeyStore trustStore = KeyStore.getInstance("JKS");

      // Open our file and read the truststore
      try (FileInputStream trustStoreInput = new FileInputStream(trustStorePath)) {
        trustStore.load(trustStoreInput, truststorePassword);
      }
      // Create a default trust and key manager
      trustManagerFactory = TrustManagerFactory.getInstance(TrustManagerFactory.getDefaultAlgorithm());
      // Initialise the managers
      trustManagerFactory.init(trustStore);
    }

    // Get an SSL context.
    SSLContext sslContext = SSLContext.getInstance("SSL");

    // Initialise our SSL context from the key/trust managers
    if (trustManagerFactory != null) {
      if (keyManagerFactory != null) {
        sslContext.init(keyManagerFactory.getKeyManagers(), trustManagerFactory.getTrustManagers(), new SecureRandom());
      } else {
        sslContext.init(null, trustManagerFactory.getTrustManagers(), new SecureRandom());
      }
    } else {
      if (keyManagerFactory != null) {
        sslContext.init(keyManagerFactory.getKeyManagers(), null, new SecureRandom());
      } else { // Get the default keystore/truststore from Java
        sslContext.init(null, null, new SecureRandom());
      }
    }
    return sslContext.getSocketFactory();
  }

  public String getKeystore() {
    System.out.println("getKeystore");
    return keystore;
  }

  public void setKeystore(String keystore) {
    System.out.println("setKeystore");
    System.setProperty("javax.net.ssl.keyStore",keystore);
    this.keystore = keystore;
  }

  public void setKeystoreProvider(String keystoreProvider) {
    System.out.println("setKeystoreProvider");
    System.setProperty("javax.net.ssl.keyStoreProvider",keystoreProvider);
    this.keystoreProvider = keystoreProvider;
  }

  public void setTruststoreProvider(String truststoreProvider) {
    System.out.println("setTruststoreProvider");
    System.setProperty("javax.net.ssl.trustStoreProvider",truststoreProvider);
    this.truststoreProvider = truststoreProvider;
  }

  public void setcertAlias(String certAlias) {
    System.out.println("setcertAlias");
    System.setProperty("javax.net.ssl.certAlias",certAlias);
    this.certAlias = certAlias;
  }

  public void setuseIBMCipherMappings(String useIBMCipherMappings) {
    System.out.println("setuseIBMCipherMappings");
    System.setProperty("com.ibm.mq.cfg.useIBMCipherMappings", useIBMCipherMappings);
    this.useIBMCipherMappings = useIBMCipherMappings;
  }

  public String getTruststore() {
    System.out.println("getTruststore");
    return truststore;
  }

  public void setprotocols(String protocols) {
    System.out.println("setprotocols");
    System.setProperty("jdk.tls.client.protocols", protocols);
    this.protocols = protocols;
  }
  public void setCipherSuite(String cipherSuite) {
    System.out.println("setCipherSuite");
    System.setProperty("jdk.tls.client.cipherSuites", cipherSuite);
    System.setProperty("jdk.tls.server.cipherSuites", cipherSuite);
    this.cipherSuite = cipherSuite;
  }

  public void setTruststore(String truststore) {
    System.out.println("setTruststore");
    System.setProperty("javax.net.ssl.trustStore", truststore);
    this.truststore = truststore;
  }

  public void setkeystoreType(String keystoreType) {
    System.out.println("setkeystoreType");
    System.setProperty("javax.net.ssl.keystoreType", keystoreType);
    this.keystoreType = keystoreType;
  }

  public String getTruststorePassword() {
    System.out.println("getTruststorePassword");
    return truststorePassword;
  }

  public void setTruststorePassword(String truststorePassword) {
    System.out.println("setTruststorePassword");
    System.setProperty("javax.net.ssl.trustStorePassword", truststorePassword);
    this.truststorePassword = truststorePassword;
  }

  public String getKeystorePassword() {
    System.out.println("getKeystorePassword");
    return keystorePassword;
  }

  public void setKeystorePassword(String keystorePassword) {
    System.out.println("setKeystorePassword");
    System.setProperty("javax.net.ssl.keyStorePassword",keystorePassword);
    this.keystorePassword = keystorePassword;
  }

  public SSLSocketFactory getSSLSocketFactory() throws Exception {
    System.out.println("getSSLSocketFactory");
    if (SSLSocketFactory == null) {
      SSLSocketFactory = createSSLSocketFactory(keystore, truststore, keystorePassword.toCharArray(), truststorePassword.toCharArray(), keystorePassword.toCharArray());
    }
    return SSLSocketFactory;
  }

  public void setSSLSocketFactory(SSLSocketFactory sSLSocketFactory) {
    SSLSocketFactory = sSLSocketFactory;
  }

}
