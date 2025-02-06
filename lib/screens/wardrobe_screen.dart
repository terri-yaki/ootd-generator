// File: lib/screens/wardrobe_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/clothing_item.dart';
import '../models/wardrobe_data.dart';

enum SortOption {
  alphabetical,
  category,
  tagAlphabetical,
}

class WardrobeScreen extends StatefulWidget {
  const WardrobeScreen({super.key});
  @override
  State<WardrobeScreen> createState() => _WardrobeScreenState();
}

class _WardrobeScreenState extends State<WardrobeScreen> {
  final ImagePicker _picker = ImagePicker();

  // Sorting state
  SortOption _currentSort = SortOption.alphabetical;
  bool _ascending = true;

  // Color constants as provided.
  final Color _tan = const Color(0xFFD9CBA3);
  final Color _caramel = const Color(0xFFB29C70);
  final Color _mochabrown = const Color(0xFF7B6D47);

  //- Helper: get the placeholder image path based on category.
  String getPlaceholderForCategory(ClothingCategory? category) {
    switch (category) {
      case ClothingCategory.top:
        return 'assets/top_placeholder.png';
      case ClothingCategory.bottom:
        return 'assets/bottom_placeholder.png';
      case ClothingCategory.footwear:
        return 'assets/footwear_placeholder.png';
      case ClothingCategory.accessory:
        return 'assets/accessories_placeholder.png';
      default:
        return 'assets/top_placeholder.png';
    }
  }

  // Helper function to get proper image provider.
  ImageProvider getImageProvider(String imagePath) {
    if (imagePath.startsWith('assets/')) {
      return AssetImage(imagePath);
    } else {
      return FileImage(File(imagePath));
    }
  }

  // Pick an image from gallery.
  Future<File?> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    return pickedFile != null ? File(pickedFile.path) : null;
  }

  /// Add a new clothing item using Hive for persistence.
  Future<void> _addItem({
    required String imagePath,
    required String name,
    required List<String> tags,
    required ClothingCategory category,
  }) async {
    final newItem = ClothingItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      imagePath: imagePath,
      name: name, // If empty, remains empty.
      tags: tags,
      category: category,
    );
    await WardrobeData.addItem(newItem);
    setState(() {}); // Refresh UI.
  }

  /// Edit an existing clothing item using Hive.
  Future<void> _editClothingItem(ClothingItem oldItem, {
    required String imagePath,
    required String name,
    required List<String> tags,
    required ClothingCategory category,
  }) async {
    final updatedItem = ClothingItem(
      id: oldItem.id,
      imagePath: imagePath,
      name: name,
      tags: tags,
      category: category,
    );
    // Directly update the Hive box.
    await WardrobeData.box.put(oldItem.id, updatedItem);
    setState(() {}); // Refresh UI.
  }

  /// Delete an item with confirmation using Hive.
  Future<void> _deleteItem(ClothingItem item) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Item'),
        content: const Text('Are you sure you want to delete this item?'),
        actions: [
          TextButton(
            style: TextButton.styleFrom(foregroundColor: _caramel),
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: _tan),
            onPressed: () => Navigator.pop(context, true),
            child: const Icon(Icons.delete),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await WardrobeData.deleteItem(item.id);
      setState(() {}); // Refresh UI.
      Navigator.pop(context); // Close the edit dialog.
    }
  }

  // Dialog to add a new item.
  Future<void> _showAddItemDialog() async {
    final _formKey = GlobalKey<FormState>();
    String? itemName;
    String? tagInput;
    ClothingCategory? selectedCategory;
    File? selectedImage;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) => AlertDialog(
            contentPadding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
            title: const Text('Add Item', textAlign: TextAlign.center),
            content: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Optional image picker.
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(backgroundColor: _tan),
                      icon: const Icon(Icons.photo_library),
                      label: const Text('Upload Picture'),
                      onPressed: () async {
                        final image = await _pickImage();
                        if (image != null) {
                          setStateDialog(() {
                            selectedImage = image;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    // Preview: either the uploaded image or a placeholder based on category.
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        image: DecorationImage(
                          image: selectedImage != null
                              ? FileImage(selectedImage!)
                              : AssetImage(getPlaceholderForCategory(selectedCategory)) as ImageProvider,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Optional item name.
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Item Name',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      onSaved: (value) => itemName = value?.trim() ?? '',
                    ),
                    const SizedBox(height: 16),
                    // Required category.
                    DropdownButtonFormField<ClothingCategory>(
                      decoration: const InputDecoration(
                        labelText: 'Category *',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      items: ClothingCategory.values.map((category) {
                        return DropdownMenuItem(
                          value: category,
                          child: Text(category.toString().split('.').last.toUpperCase()),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setStateDialog(() {
                          selectedCategory = value;
                        });
                      },
                      validator: (value) => value == null ? 'Select a category' : null,
                    ),
                    const SizedBox(height: 16),
                    // Optional style tags.
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Style Tags (comma separated)',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      onSaved: (value) => tagInput = value,
                    ),
                  ],
                ),
              ),
            ),
            actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            actions: [
              TextButton(
                style: TextButton.styleFrom(foregroundColor: _caramel),
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: _tan),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    final tags = (tagInput != null && tagInput!.isNotEmpty)
                        ? tagInput!.split(',').map((t) => t.trim()).toList()
                        : <String>[];
                    _addItem(
                      imagePath: selectedImage?.path ?? getPlaceholderForCategory(selectedCategory),
                      name: itemName ?? '',
                      tags: tags,
                      category: selectedCategory!,
                    );
                    Navigator.pop(context);
                  }
                },
                child: const Icon(Icons.add),
              ),
            ],
          ),
        );
      },
    );
  }

  // Dialog to edit an existing item.
  Future<void> _showEditItemDialog(ClothingItem item) async {
    final _formKey = GlobalKey<FormState>();
    String? itemName = item.name;
    String? tagInput = item.tags.join(', ');
    ClothingCategory selectedCategory = item.category;
    File? selectedImage;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) => AlertDialog(
            contentPadding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
            title: const Text('Edit Item', textAlign: TextAlign.center),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // Image picker for reupload.
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(backgroundColor: _tan),
                          icon: const Icon(Icons.photo_library),
                          label: const Text('Reupload Picture'),
                          onPressed: () async {
                            final image = await _pickImage();
                            if (image != null) {
                              setStateDialog(() {
                                selectedImage = image;
                              });
                            }
                          },
                        ),
                        const SizedBox(height: 16),
                        // Display current or reuploaded image.
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            image: DecorationImage(
                              image: selectedImage != null
                                  ? FileImage(selectedImage!)
                                  : getImageProvider(item.imagePath),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Editable item name.
                        TextFormField(
                          initialValue: itemName,
                          decoration: const InputDecoration(
                            labelText: 'Item Name',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                          onSaved: (value) => itemName = value?.trim() ?? '',
                        ),
                        const SizedBox(height: 16),
                        // Category (required).
                        DropdownButtonFormField<ClothingCategory>(
                          value: selectedCategory,
                          decoration: const InputDecoration(
                            labelText: 'Category *',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                          items: ClothingCategory.values.map((category) {
                            return DropdownMenuItem(
                              value: category,
                              child: Text(category.toString().split('.').last.toUpperCase()),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setStateDialog(() {
                                selectedCategory = value;
                              });
                            }
                          },
                          validator: (value) => value == null ? 'Select a category' : null,
                        ),
                        const SizedBox(height: 16),
                        // Editable style tags.
                        TextFormField(
                          initialValue: tagInput,
                          decoration: const InputDecoration(
                            labelText: 'Style Tags (comma separated)',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                          onSaved: (value) => tagInput = value,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Row for action buttons: Delete on left, Cancel and Save on right.
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Delete button (trash bin icon) stays at left.
                      IconButton(
                        style: TextButton.styleFrom(foregroundColor: Colors.red),
                        onPressed: () => _deleteItem(item),
                        icon: const Icon(Icons.delete),
                      ),
                      Row(
                        children: [
                          TextButton(
                            style: TextButton.styleFrom(foregroundColor: _caramel),
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel'),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: _tan),
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                _formKey.currentState!.save();
                                final tags = (tagInput != null && tagInput!.isNotEmpty)
                                    ? tagInput!.split(',').map((t) => t.trim()).toList()
                                    : <String>[];
                                _editClothingItem(
                                  item,
                                  imagePath: selectedImage?.path ?? item.imagePath,
                                  name: itemName ?? '',
                                  tags: tags,
                                  category: selectedCategory,
                                );
                                Navigator.pop(context);
                              }
                            },
                            child: const Text('Save'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Returns a sorted copy of wardrobe items.
  List<ClothingItem> _getSortedItems() {
    List<ClothingItem> sorted = List.from(WardrobeData.items);
    int compare<T extends Comparable>(T a, T b) => _ascending ? a.compareTo(b) : b.compareTo(a);
    switch (_currentSort) {
      case SortOption.alphabetical:
        sorted.sort((a, b) => compare(a.name.toLowerCase(), b.name.toLowerCase()));
        break;
      case SortOption.category:
        int categoryOrder(ClothingCategory c) {
          switch (c) {
            case ClothingCategory.top:
              return 0;
            case ClothingCategory.bottom:
              return 1;
            case ClothingCategory.footwear:
              return 2;
            case ClothingCategory.accessory:
              return 3;
          }
        }
        sorted.sort((a, b) => compare(categoryOrder(a.category), categoryOrder(b.category)));
        break;
      case SortOption.tagAlphabetical:
        String firstTag(ClothingItem item) => item.tags.isNotEmpty ? item.tags.first.toLowerCase() : '';
        sorted.sort((a, b) => compare(firstTag(a), firstTag(b)));
        break;
    }
    return sorted;
  }

  @override
  Widget build(BuildContext context) {
    final sortedItems = _getSortedItems();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wardrobe'),
        centerTitle: true,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort),
            onSelected: (value) {
              setState(() {
                if (value == 'Alphabetical') {
                  _currentSort = SortOption.alphabetical;
                } else if (value == 'Category') {
                  _currentSort = SortOption.category;
                } else if (value == 'Tag') {
                  _currentSort = SortOption.tagAlphabetical;
                } else if (value == 'Toggle') {
                  _ascending = !_ascending;
                }
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'Alphabetical',
                child: Text('Sort Alphabetically'),
              ),
              const PopupMenuItem(
                value: 'Category',
                child: Text('Sort by Category'),
              ),
              const PopupMenuItem(
                value: 'Tag',
                child: Text('Sort by Tag'),
              ),
              const PopupMenuDivider(),
              PopupMenuItem(
                value: 'Toggle',
                child: Text(_ascending ? 'Descending' : 'Ascending'),
              ),
            ],
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0), // Larger overall margin.
        child: sortedItems.isEmpty
            ? const Center(
                child: Padding(
                  padding: EdgeInsets.only(bottom: 30),
                  child: Text(
                    'No item available yet :(',
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            : LayoutBuilder(
                builder: (context, constraints) {
                  int crossAxisCount = constraints.maxWidth < 300 ? 1 : 2;
                  return GridView.builder(
                    itemCount: sortedItems.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 1, // Square items.
                    ),
                    itemBuilder: (context, index) {
                      final item = sortedItems[index];
                      return InkWell(
                        onTap: () => _showEditItemDialog(item),
                        child: AspectRatio(
                          aspectRatio: 1,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color.fromARGB(255, 102, 89, 64).withOpacity(0.3),
                                  offset: const Offset(5, 5), // 5px offset to bottom right.
                                  blurRadius: 10,
                                ),
                              ],
                            ),
                            child: Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 0, // Shadow provided by parent container.
                              clipBehavior: Clip.antiAlias,
                              child: Container(
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: getImageProvider(item.imagePath),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
      ),
      floatingActionButton: Padding(
        // Raise the add item button by 30px.
        padding: const EdgeInsets.only(bottom: 30),
        child: FloatingActionButton(
          backgroundColor: _caramel,
          onPressed: _showAddItemDialog,
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
