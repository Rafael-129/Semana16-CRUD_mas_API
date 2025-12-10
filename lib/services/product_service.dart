import 'package:dio/dio.dart';
import '../models/product.dart';

class ProductService {
  final Dio _dio;
  static const String baseUrl = 'http://localhost:3000/api';

  ProductService()
    : _dio = Dio(
        BaseOptions(
          baseUrl: baseUrl,
          connectTimeout: const Duration(seconds: 5),
          receiveTimeout: const Duration(seconds: 3),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      ) {
    // Interceptor para logs (útil para debugging)
    _dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        error: true,
        requestHeader: false,
        responseHeader: false,
      ),
    );
  }

  // CREATE - Crear un nuevo producto
  Future<Product> createProduct(Product product) async {
    try {
      final response = await _dio.post('/productos', data: product.toJson());

      if (response.statusCode == 201) {
        return Product.fromJson(response.data['producto']);
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Error al crear el producto',
        );
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // READ - Obtener todos los productos
  Future<List<Product>> getProducts() async {
    try {
      final response = await _dio.get('/productos');

      if (response.statusCode == 200) {
        final List<dynamic> productsJson = response.data['productos'];
        return productsJson.map((json) => Product.fromJson(json)).toList();
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Error al obtener productos',
        );
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // READ - Obtener un producto por ID
  Future<Product> getProduct(int id) async {
    try {
      final response = await _dio.get('/productos/$id');

      if (response.statusCode == 200) {
        return Product.fromJson(response.data['producto']);
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Producto no encontrado',
        );
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // UPDATE - Actualizar un producto
  Future<Product> updateProduct(int id, Product product) async {
    try {
      final response = await _dio.put('/productos/$id', data: product.toJson());

      if (response.statusCode == 200) {
        return Product.fromJson(response.data['producto']);
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Error al actualizar el producto',
        );
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // DELETE - Eliminar un producto
  Future<void> deleteProduct(int id) async {
    try {
      final response = await _dio.delete('/productos/$id');

      if (response.statusCode != 200) {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Error al eliminar el producto',
        );
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Manejador de errores centralizado
  String _handleError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Error de conexión: Tiempo de espera agotado';

      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        if (statusCode == 404) {
          return 'Recurso no encontrado';
        } else if (statusCode == 400) {
          return 'Solicitud incorrecta: ${error.response?.data['error'] ?? 'Error desconocido'}';
        } else if (statusCode == 500) {
          return 'Error del servidor';
        }
        return 'Error HTTP: $statusCode';

      case DioExceptionType.cancel:
        return 'Solicitud cancelada';

      case DioExceptionType.unknown:
        if (error.error.toString().contains('SocketException')) {
          return 'Sin conexión a internet o servidor no disponible';
        }
        return 'Error desconocido: ${error.message}';

      default:
        return 'Error inesperado: ${error.message}';
    }
  }
}
