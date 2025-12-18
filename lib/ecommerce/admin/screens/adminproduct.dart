import 'package:crypto_app/ecommerce/admin/products/adminproductProvider.dart';
import 'package:crypto_app/ecommerce/models/productmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Adminproduct extends ConsumerWidget {
  const Adminproduct({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productasync = ref.watch(stramprodcts);


    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Products'),
        elevation: 0,
        backgroundColor: const Color(0xFF1a1a2e),
      ),
      backgroundColor: const Color(0xFF0f0f1e),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFFF6B6B),
        onPressed: () {
          TextEditingController titleController = TextEditingController();
          TextEditingController priceController = TextEditingController();
          TextEditingController imageController = TextEditingController();
          TextEditingController descriptionController = TextEditingController();
          TextEditingController categoryController = TextEditingController();
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              backgroundColor: const Color(0xFF16213e),
              title: const Text(
                'Add New Product',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildTextField(titleController, 'Title',TextInputType.text),
                    _buildTextField(priceController, 'Price',TextInputType.number),
                    _buildTextField(imageController, 'Image URL', TextInputType.url),
                    _buildTextField(descriptionController, 'Description', TextInputType.multiline),
                    _buildTextField(categoryController, 'Category', TextInputType.text),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    ref
                        .read(admincontrollProvider)
                        .addProduct(
                          Product(
                            id: '',
                            title: titleController.text,
                            price: double.tryParse(priceController.text) ?? 0.0,
                            image: imageController.text,
                            description: descriptionController.text,
                            category: categoryController.text,
                          ),
                        );
                    Navigator.of(context).pop();
                  },
                  child: const Text(
                    'Add',
                    style: TextStyle(color: Color(0xFFFF6B6B)),
                  ),
                ),
              ],
            ),
          );
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: productasync.when(
        data: (product) {
          if (product.docs.isEmpty) {
            return const Center(
              child: Text(
                'No products available',
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: product.docs.length,
            itemBuilder: (_, i) {
              final docs = product.docs[i];
              final p = docs.data() as Map<String, dynamic>;
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF16213e),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withOpacity(0.08)),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  leading: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.grey[800],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        p['image'] ?? '',
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            const Icon(Icons.image, color: Colors.grey),
                      ),
                    ),
                  ),
                  title: Text(
                    p['title'] ?? 'No Title',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(
                        'Price: \$${p['price'] ?? 0.0}',
                        style: const TextStyle(
                          color: Color(0xFFFF6B6B),
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        'Category: ${p['category'] ?? 'N/A'}',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              backgroundColor: const Color(0xFF16213e),
                              title: const Text(
                                'Delete Product',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              content: const Text(
                                'Are you sure you want to delete this product?',
                                style: TextStyle(color: Colors.grey),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text(
                                    'Cancel',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    ref
                                        .read(admincontrollProvider)
                                        .deleteproduct(
                                          //stream provider avayathond (data) matti map use akiyittund
                                          Product.fromMap(
                                            docs.data() as Map<String, dynamic>,
                                            docs.id,
                                          ),
                                        );
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text(
                                    'Delete',
                                    style: TextStyle(color: Color(0xFFFF6B6B)),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Color(0xFFFF6B6B),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          TextEditingController titleController =
                              TextEditingController();
                          TextEditingController priceController =
                              TextEditingController();
                          TextEditingController imageController =
                              TextEditingController();
                          TextEditingController descriptionController =
                              TextEditingController();
                          TextEditingController categoryController =
                              TextEditingController();

                          titleController.text = (p["title"]);
                          priceController.text = p["price"].toString();
                          imageController.text = p["image"];
                          descriptionController.text = p["image"];
                          categoryController.text = p["category"];
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              backgroundColor: const Color(0xFF16213e),
                              title: const Text(
                                'Update Product',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              content: SingleChildScrollView(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    _buildTextField(titleController, 'Title',TextInputType.text),
                                    _buildTextField(priceController, 'Price',TextInputType.number),
                                    _buildTextField(
                                      imageController,
                                      'Image URL',
                                      TextInputType.url
                                    ),
                                    _buildTextField(
                                      descriptionController,
                                      'Description',
                                      TextInputType.multiline
                                    ),
                                    _buildTextField(
                                      categoryController,
                                      'Category',
                                      TextInputType.text
                                    ),
                                  ],
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text(
                                    'Cancel',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    ref.read(admincontrollProvider).updateProduct(Product(
                                      id: docs.id,
                                      title: titleController.text,
                                      price: double.tryParse(
                                              priceController.text) ??
                                          0.0,
                                      image: imageController.text,
                                      description: descriptionController.text,
                                      category: categoryController.text,
                                    ));
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text(
                                    'update',
                                    style: TextStyle(color: Color(0xFFFF6B6B)),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                        icon: const Icon(
                          Icons.edit_outlined,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        error: (err, stack) => Center(
          child: Text('Error: $err', style: const TextStyle(color: Colors.red)),
        ),
        loading: () => const Center(
          child: CircularProgressIndicator(color: Color(0xFFFF6B6B)),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint,TextInputType type) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        keyboardType: type,
        controller: controller,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: hint,
          
          hintStyle: const TextStyle(color: Colors.grey),
          filled: true,
          fillColor: const Color(0xFF0f0f1e),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFFFF6B6B)),
          ),
        ),
      ),
    );
  }
}
