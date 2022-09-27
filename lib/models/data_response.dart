class DataResponse {

  int statusCode;
  Map<String, dynamic> data;

  DataResponse({required this.data, required this.statusCode});
}