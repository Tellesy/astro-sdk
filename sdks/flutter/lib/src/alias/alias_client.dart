import '../astro_http.dart';
import '../models/models.dart';

class AliasClient {
  final AstroHttpClient _http;
  const AliasClient(this._http);

  Future<AliasProfile> getProfile(String alias) async {
    final json = await _http.get('/alias/$alias');
    return AliasProfile.fromJson(json as Map<String, dynamic>);
  }

  Future<List<LinkedAccount>> getAccounts(String alias) async {
    final json = await _http.get('/alias/$alias/accounts');
    final list = (json as Map<String, dynamic>)['accounts'] as List;
    return list.map((e) => LinkedAccount.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<AliasProfile> deactivate(String alias) async {
    final json = await _http.post('/alias/$alias/deactivate');
    return AliasProfile.fromJson(json as Map<String, dynamic>);
  }

  /// Bank-server only. UNKNOWN is a registry transport state, not availability.
  Future<AliasAvailability> availability(String alias) async {
    final encoded = Uri.encodeComponent(alias);
    final json = await _http.get('/alias/$encoded/availability');
    return AliasAvailability.fromJson(json as Map<String, dynamic>);
  }

  /// Bank-server only. Identity permanently retires the previous NPT name.
  Future<RenameAliasResult> rename(RenameAliasRequest request) async {
    final json = await _http.patch('/alias/rename', request.toJson());
    return RenameAliasResult.fromJson(json as Map<String, dynamic>);
  }

  Future<ResolveResult> resolve(String alias) async {
    final json = await _http.get('/identity/resolve', params: {'alias': alias});
    return ResolveResult.fromJson(json as Map<String, dynamic>);
  }
}
