import 'environment.dart';

abstract final class ApiConfig {
	static const developmentBaseUrl = 'http://localhost:8080/api';
	static const stagingBaseUrl = 'https://staging-api.pigworld.app/api';
	static const productionBaseUrl = 'https://api.pigworld.app/api';

	static String baseUrl([Environment environment = Environment.development]) {
		switch (environment) {
			case Environment.development:
				return developmentBaseUrl;
			case Environment.staging:
				return stagingBaseUrl;
			case Environment.production:
				return productionBaseUrl;
		}
	}
}
