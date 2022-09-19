class RepositoryResponse {

  int statusCode;
  Map<String, dynamic> data;

  RepositoryResponse({required this.data, required this.statusCode});
}