import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/product_service.dart';

class EditProductScreen extends StatefulWidget {
  final Product product;

  const EditProductScreen({super.key, required this.product});

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _productService = ProductService();

  // Controladores para los campos del formulario
  late final TextEditingController _nombreController;
  late final TextEditingController _descripcionController;
  late final TextEditingController _precioController;
  late final TextEditingController _imagenController;
  late final TextEditingController _stockController;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Inicializar controladores con los datos del producto
    _nombreController = TextEditingController(text: widget.product.nombre);
    _descripcionController = TextEditingController(
      text: widget.product.descripcion,
    );
    _precioController = TextEditingController(
      text: widget.product.precio.toString(),
    );
    _imagenController = TextEditingController(text: widget.product.imagen);
    _stockController = TextEditingController(
      text: widget.product.stock.toString(),
    );
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _descripcionController.dispose();
    _precioController.dispose();
    _imagenController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  Future<void> _updateProduct() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final updatedProduct = Product(
        id: widget.product.id,
        nombre: _nombreController.text.trim(),
        descripcion: _descripcionController.text.trim(),
        precio: double.parse(_precioController.text.trim()),
        imagen: _imagenController.text.trim(),
        stock: int.parse(_stockController.text.trim()),
      );

      final result = await _productService.updateProduct(
        widget.product.id!,
        updatedProduct,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '✅ Producto "${result.nombre}" actualizado exitosamente',
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );

        // Volver a la pantalla anterior y pasar el producto actualizado
        Navigator.pop(context, result);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showDiscardDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Descartar cambios?'),
        content: const Text(
          '¿Estás seguro de que quieres descartar los cambios realizados?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Cerrar diálogo
              Navigator.pop(context); // Cerrar pantalla de edición
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Descartar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Producto'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: _showDiscardDialog,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Información del producto
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.edit, color: Colors.blue.shade700),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Editando: ${widget.product.nombre}',
                        style: TextStyle(
                          color: Colors.blue.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade100,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'ID: ${widget.product.id}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue.shade700,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Vista previa de imagen
              if (_imagenController.text.isNotEmpty)
                Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      _imagenController.text,
                      height: 120,
                      width: 120,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 120,
                          width: 120,
                          color: Colors.grey.shade200,
                          child: Icon(
                            Icons.broken_image,
                            size: 40,
                            color: Colors.grey.shade400,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              const SizedBox(height: 24),

              // Campo: Nombre
              TextFormField(
                controller: _nombreController,
                decoration: const InputDecoration(
                  labelText: 'Nombre del Producto *',
                  hintText: 'Ej: Laptop HP',
                  prefixIcon: Icon(Icons.shopping_bag),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'El nombre es obligatorio';
                  }
                  if (value.trim().length < 3) {
                    return 'El nombre debe tener al menos 3 caracteres';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Campo: Descripción
              TextFormField(
                controller: _descripcionController,
                decoration: const InputDecoration(
                  labelText: 'Descripción',
                  hintText: 'Descripción detallada del producto',
                  prefixIcon: Icon(Icons.description),
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value != null &&
                      value.trim().isNotEmpty &&
                      value.trim().length < 10) {
                    return 'La descripción debe tener al menos 10 caracteres';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Campo: Precio
              TextFormField(
                controller: _precioController,
                decoration: const InputDecoration(
                  labelText: 'Precio *',
                  hintText: '0.00',
                  prefixIcon: Icon(Icons.attach_money),
                  border: OutlineInputBorder(),
                  suffixText: 'S/',
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'El precio es obligatorio';
                  }
                  final precio = double.tryParse(value.trim());
                  if (precio == null) {
                    return 'Ingrese un precio válido';
                  }
                  if (precio <= 0) {
                    return 'El precio debe ser mayor a 0';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Campo: Stock
              TextFormField(
                controller: _stockController,
                decoration: const InputDecoration(
                  labelText: 'Stock *',
                  hintText: '0',
                  prefixIcon: Icon(Icons.inventory),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'El stock es obligatorio';
                  }
                  final stock = int.tryParse(value.trim());
                  if (stock == null) {
                    return 'Ingrese un stock válido';
                  }
                  if (stock < 0) {
                    return 'El stock no puede ser negativo';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Campo: URL de Imagen
              TextFormField(
                controller: _imagenController,
                decoration: const InputDecoration(
                  labelText: 'URL de Imagen',
                  hintText: 'https://ejemplo.com/imagen.jpg',
                  prefixIcon: Icon(Icons.image),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.url,
                onChanged: (value) {
                  // Reconstruir para actualizar vista previa
                  setState(() {});
                },
              ),
              const SizedBox(height: 24),

              // Botón: Guardar Cambios
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _updateProduct,
                icon: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.save),
                label: Text(
                  _isLoading ? 'Guardando...' : 'Guardar Cambios',
                  style: const TextStyle(fontSize: 16),
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                ),
              ),
              const SizedBox(height: 12),

              // Botón: Cancelar
              OutlinedButton.icon(
                onPressed: _isLoading ? null : _showDiscardDialog,
                icon: const Icon(Icons.cancel),
                label: const Text('Cancelar'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
              const SizedBox(height: 16),

              // Nota informativa
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.orange),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Los campos marcados con * son obligatorios',
                        style: TextStyle(color: Colors.orange),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
