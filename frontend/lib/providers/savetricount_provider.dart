import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:prbd_2425_a07/core/services/savetricount_service.dart';
import 'package:prbd_2425_a07/core/services/tricount_list_service.dart';

final save_tricount_service = Provider<savetricount_service> ((_) => tricount_list_service());