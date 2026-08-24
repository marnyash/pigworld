import 'package:flutter_riverpod/flutter_riverpod.dart';

enum ConnectivityStatus { online, offline, unknown }

final connectivityProvider = Provider<ConnectivityStatus>(
	(ref) => ConnectivityStatus.unknown,
);
