class Product {
  final int? id;
  final String nombre;
  final String descripcion;
  final double precio;
  final String imagen;
  final int stock;

  Product({
    this.id,
    required this.nombre,
    required this.descripcion,
    required this.precio,
    required this.imagen,
    required this.stock,
  });

  // Convertir de JSON a Product
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      nombre: json['nombre'] ?? '',
      descripcion: json['descripcion'] ?? '',
      precio: (json['precio'] ?? 0).toDouble(),
      imagen: json['imagen'] ?? '',
      stock: json['stock'] ?? 0,
    );
  }

  // Convertir de Product a JSON
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'nombre': nombre,
      'descripcion': descripcion,
      'precio': precio,
      'imagen': imagen,
      'stock': stock,
    };
  }

  // CopyWith para crear copias modificadas
  Product copyWith({
    int? id,
    String? nombre,
    String? descripcion,
    double? precio,
    String? imagen,
    int? stock,
  }) {
    return Product(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      descripcion: descripcion ?? this.descripcion,
      precio: precio ?? this.precio,
      imagen: imagen ?? this.imagen,
      stock: stock ?? this.stock,
    );
  }

  @override
  String toString() {
    return 'Product(id: $id, nombre: $nombre, precio: $precio, stock: $stock)';
  }
}
