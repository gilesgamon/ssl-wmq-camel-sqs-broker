package consulting.lsiarchi.mrb;

import org.apache.camel.spring.Main;

public class brokerRouter {
	public static void main(String[] args) throws Exception {
		Main main = new Main();
		main.setApplicationContextUri("classpath:camel-context.xml");
		// main.setApplicationContextUri("META-INF/spring/camel-context.xml");
		System.setProperty("javax.net.ssl.trustStore", "server-chain.jks");
		main.run();
	}
}