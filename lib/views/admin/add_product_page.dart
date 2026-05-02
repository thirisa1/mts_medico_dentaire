// import 'dart:io';
// import 'dart:typed_data';
// import 'package:flutter/foundation.dart' show kIsWeb;
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import '../../model/product.dart';
// import '../../restrictions/validators.dart'; // ← IMPORTANT : Ajouter cette import
// import '../../services/product_service.dart';
// import '../../style/theme/colors.dart';
// import '../../widgets/app_text_field.dart';

// class AddProductPage extends StatefulWidget {
//   const AddProductPage({super.key, required this.onProductAdded});

//   final void Function(Product product) onProductAdded;

//   @override
//   State<AddProductPage> createState() => _AddProductPageState();
// }

// class _AddProductPageState extends State<AddProductPage> {
//   final _nameCtrl = TextEditingController();
//   final _brandCtrl = TextEditingController();
//   final _quantityCtrl = TextEditingController();
//   final _priceCtrl = TextEditingController();
//   final _descriptionCtrl = TextEditingController();

//   ProductCategory? _selectedCategory;
//   final Set<BuyerType> _selectedBuyers = {};
//   XFile? _pickedImage;
//   final _picker = ImagePicker();
//   bool _isLoading = false;

//   @override
//   void dispose() {
//     _nameCtrl.dispose();
//     _brandCtrl.dispose();
//     _quantityCtrl.dispose();
//     _priceCtrl.dispose();
//     _descriptionCtrl.dispose();
//     super.dispose();
//   }

//   // ── Validation et soumission ──
//   void _submit() async {
//     final name = _nameCtrl.text.trim();
//     final brand = _brandCtrl.text.trim();
//     final quantityStr = _quantityCtrl.text.trim();
//     final priceStr = _priceCtrl.text.trim();
//     final description = _descriptionCtrl.text.trim();

//     // Validations
//     final nameError = AppValidators.name(name);
//     if (nameError != null) {
//       _showError(nameError);
//       return;
//     }

//     final brandError = AppValidators.name(brand);
//     if (brandError != null) {
//       _showError('Marque : $brandError');
//       return;
//     }

//     if (_selectedCategory == null) {
//       _showError('Veuillez sélectionner une catégorie.');
//       return;
//     }

//     final quantity = int.tryParse(quantityStr);
//     if (quantityStr.isEmpty || quantity == null || quantity < 0) {
//       _showError('Quantité invalide.');
//       return;
//     }

//     final price = double.tryParse(priceStr.replaceAll(',', '.'));
//     if (priceStr.isEmpty || price == null || price <= 0) {
//       _showError('Prix invalide.');
//       return;
//     }

//     if (_selectedBuyers.isEmpty) {
//       _showError('Sélectionnez au moins un type d\'acheteur autorisé.');
//       return;
//     }

//     setState(() => _isLoading = true);

//     try {
//       // Préparer les bytes de l'image si elle existe
//       Uint8List? imageBytes;
//       String? imageFileName;

//       if (_pickedImage != null) {
//         imageBytes = await _pickedImage!.readAsBytes();
//         imageFileName = _pickedImage!.name;
//       }

//       // ✅ APPEL CORRECT À FIREBASE AVEC LES PARAMÈTRES NOMMÉS
//       final newProduct = await ProductService.addProduct(
//         Product(
//           id: '',
//           name: name,
//           brand: brand,
//           category: _selectedCategory!,
//           quantity: quantity,
//           price: price,
//           description: description,
//           allowedBuyers: _selectedBuyers.toList(),
//           imagePath: null,
//         ),
//         nom: name,
//         marque: brand,
//         category: _selectedCategory!,
//         prix: price,
//         quantite: quantity,
//         description: description,
//         acheteurs: _selectedBuyers.toList(),
//         imageBytes: imageBytes,
//         imageFileName: imageFileName,
//       );

//       if (!mounted) return;

//       kProducts.add(newProduct);
//       widget.onProductAdded(newProduct);

//       setState(() => _isLoading = false);
//       Navigator.pop(context);

//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Row(
//             children: [
//               const Icon(
//                 Icons.check_circle_outline_rounded,
//                 color: Colors.white,
//               ),
//               const SizedBox(width: 10),
//               Flexible(child: Text('« $name » ajouté au catalogue !')),
//             ],
//           ),
//           backgroundColor: AppColors.green,
//           behavior: SnackBarBehavior.floating,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(12),
//           ),
//           margin: const EdgeInsets.all(16),
//           duration: const Duration(seconds: 3),
//         ),
//       );
//     } catch (e) {
//       if (mounted) {
//         setState(() => _isLoading = false);
//         _showError('Erreur lors de l\'ajout du produit: $e');
//       }
//     }
//   }

//   void _showError(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         backgroundColor: const Color(0xFFD32F2F),
//         behavior: SnackBarBehavior.floating,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//         margin: const EdgeInsets.all(16),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.background,
//       appBar: _buildAppBar(),
//       body: _buildBody(),
//       bottomNavigationBar: _buildBottomBar(),
//     );
//   }

//   // ── AppBar ──
//   PreferredSizeWidget _buildAppBar() {
//     return PreferredSize(
//       preferredSize: const Size.fromHeight(kToolbarHeight),
//       child: Container(
//         decoration: BoxDecoration(
//           gradient: AppColors.appBarGradient,
//           boxShadow: [
//             BoxShadow(
//               color: AppColors.shadowDeep,
//               blurRadius: 12,
//               offset: const Offset(0, 4),
//             ),
//           ],
//         ),
//         child: AppBar(
//           backgroundColor: Colors.transparent,
//           elevation: 0,
//           leading: IconButton(
//             icon: const Icon(
//               Icons.close_rounded,
//               color: Colors.white,
//               size: 22,
//             ),
//             onPressed: () => Navigator.pop(context),
//           ),
//           title: const Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Text(
//                 'Nouveau produit',
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontWeight: FontWeight.w800,
//                   fontSize: 17,
//                 ),
//               ),
//               Text(
//                 'Remplir les informations',
//                 style: TextStyle(color: Color(0xAAFFFFFF), fontSize: 10),
//               ),
//             ],
//           ),
//           centerTitle: true,
//         ),
//       ),
//     );
//   }

//   // ── Body ──
//   Widget _buildBody() {
//     return SingleChildScrollView(
//       padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // ── Photo du produit ──
//           _sectionTitle('Photo du produit', Icons.photo_camera_outlined),
//           const SizedBox(height: 14),
//           _buildImagePicker(),
//           const SizedBox(height: 24),

//           // ── Section Informations générales ──
//           _sectionTitle('Informations générales', Icons.info_outline_rounded),
//           const SizedBox(height: 14),
//           AppTextField(
//             controller: _nameCtrl,
//             label: 'Nom du produit *',
//             icon: Icons.inventory_2_outlined,
//             inputFormatters: AppFormatters.name,
//           ),
//           const SizedBox(height: 14),
//           AppTextField(
//             controller: _brandCtrl,
//             label: 'Marque *',
//             icon: Icons.branding_watermark_outlined,
//             inputFormatters: AppFormatters.name,
//           ),
//           const SizedBox(height: 14),

//           // ── Catégorie ──
//           _sectionTitle('Catégorie *', Icons.category_outlined),
//           const SizedBox(height: 10),
//           _buildCategoryGrid(),
//           const SizedBox(height: 24),

//           // ── Stock & Prix ──
//           _sectionTitle('Stock & Prix', Icons.monetization_on_outlined),
//           const SizedBox(height: 14),
//           Row(
//             children: [
//               Expanded(
//                 child: AppTextField(
//                   controller: _quantityCtrl,
//                   label: 'Quantité *',
//                   icon: Icons.layers_outlined,
//                   keyboardType: TextInputType.number,
//                   inputFormatters: AppFormatters.digitsOnly,
//                 ),
//               ),
//               const SizedBox(width: 14),
//               Expanded(
//                 child: AppTextField(
//                   controller: _priceCtrl,
//                   label: 'Prix (DA) *',
//                   icon: Icons.sell_outlined,
//                   keyboardType: const TextInputType.numberWithOptions(
//                     decimal: true,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 24),

//           // ── Description ──
//           _sectionTitle('Description', Icons.description_outlined),
//           const SizedBox(height: 14),
//           _buildDescriptionField(),
//           const SizedBox(height: 24),

//           // ── Acheteurs autorisés ──
//           _sectionTitle('Acheteurs autorisés *', Icons.people_outline_rounded),
//           const SizedBox(height: 4),
//           Text(
//             'Qui a le droit d\'acheter ce produit ?',
//             style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
//           ),
//           const SizedBox(height: 12),
//           _buildBuyerSelection(),
//         ],
//       ),
//     );
//   }

//   // ── Titre de section ──
//   Widget _sectionTitle(String title, IconData icon) {
//     return Row(
//       children: [
//         Container(
//           width: 32,
//           height: 32,
//           decoration: BoxDecoration(
//             color: AppColors.primaryLight,
//             borderRadius: BorderRadius.circular(8),
//           ),
//           child: Icon(icon, color: AppColors.primary, size: 18),
//         ),
//         const SizedBox(width: 10),
//         Text(
//           title,
//           style: TextStyle(
//             color: AppColors.textPrimary,
//             fontWeight: FontWeight.w700,
//             fontSize: 15,
//           ),
//         ),
//       ],
//     );
//   }

//   // ── Sélecteur de photo ──
//   Future<void> _pickImage(ImageSource source) async {
//     try {
//       final picked = await _picker.pickImage(
//         source: source,
//         imageQuality: 85,
//         maxWidth: 800,
//       );
//       if (picked != null) setState(() => _pickedImage = picked);
//     } catch (_) {
//       _showError('Impossible d\'accéder à la galerie/caméra.');
//     }
//   }

//   Widget _buildImagePicker() {
//     return GestureDetector(
//       onTap: () => _showImageSourceDialog(),
//       child: AnimatedContainer(
//         duration: const Duration(milliseconds: 250),
//         width: double.infinity,
//         height: 180,
//         decoration: BoxDecoration(
//           color: AppColors.surfaceAlt,
//           borderRadius: BorderRadius.circular(16),
//           border: Border.all(
//             color:
//                 _pickedImage != null
//                     ? AppColors.accent
//                     : AppColors.textHint.withOpacity(0.4),
//             width: _pickedImage != null ? 2 : 1.5,
//             style: _pickedImage != null ? BorderStyle.solid : BorderStyle.solid,
//           ),
//         ),
//         child:
//             _pickedImage != null
//                 ? _buildImagePreview()
//                 : _buildImagePlaceholder(),
//       ),
//     );
//   }

//   Widget _buildImagePlaceholder() {
//     return Column(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         Container(
//           width: 56,
//           height: 56,
//           decoration: BoxDecoration(
//             color: AppColors.accentLight,
//             borderRadius: BorderRadius.circular(16),
//           ),
//           child: const Icon(
//             Icons.add_photo_alternate_outlined,
//             color: AppColors.accent,
//             size: 28,
//           ),
//         ),
//         const SizedBox(height: 12),
//         Text(
//           'Ajouter une photo',
//           style: TextStyle(
//             color: AppColors.textPrimary,
//             fontWeight: FontWeight.w600,
//             fontSize: 14,
//           ),
//         ),
//         const SizedBox(height: 4),
//         Text(
//           'Appuyez pour choisir depuis la galerie ou la caméra',
//           textAlign: TextAlign.center,
//           style: TextStyle(color: AppColors.textMuted, fontSize: 12),
//         ),
//       ],
//     );
//   }

//   Widget _buildImagePreview() {
//     return Stack(
//       fit: StackFit.expand,
//       children: [
//         // Image
//         ClipRRect(
//           borderRadius: BorderRadius.circular(14),
//           child:
//               kIsWeb
//                   ? Image.network(_pickedImage!.path, fit: BoxFit.cover)
//                   : Image.file(File(_pickedImage!.path), fit: BoxFit.cover),
//         ),
//         // Overlay sombre en bas
//         Positioned(
//           bottom: 0,
//           left: 0,
//           right: 0,
//           child: Container(
//             padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//             decoration: BoxDecoration(
//               borderRadius: const BorderRadius.only(
//                 bottomLeft: Radius.circular(14),
//                 bottomRight: Radius.circular(14),
//               ),
//               gradient: LinearGradient(
//                 begin: Alignment.topCenter,
//                 end: Alignment.bottomCenter,
//                 colors: [Colors.transparent, Colors.black.withOpacity(0.55)],
//               ),
//             ),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 const Text(
//                   'Photo sélectionnée',
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontSize: 12,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//                 GestureDetector(
//                   onTap: () => _showImageSourceDialog(),
//                   child: Container(
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 10,
//                       vertical: 4,
//                     ),
//                     decoration: BoxDecoration(
//                       color: Colors.white.withOpacity(0.25),
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                     child: const Text(
//                       'Changer',
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontSize: 11,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//         // Bouton supprimer
//         Positioned(
//           top: 8,
//           right: 8,
//           child: GestureDetector(
//             onTap: () => setState(() => _pickedImage = null),
//             child: Container(
//               padding: const EdgeInsets.all(6),
//               decoration: BoxDecoration(
//                 color: Colors.black.withOpacity(0.5),
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               child: const Icon(
//                 Icons.close_rounded,
//                 color: Colors.white,
//                 size: 16,
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   void _showImageSourceDialog() {
//     showModalBottomSheet(
//       context: context,
//       backgroundColor: Colors.transparent,
//       builder:
//           (_) => Container(
//             padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
//             decoration: BoxDecoration(
//               color: AppColors.surface,
//               borderRadius: const BorderRadius.vertical(
//                 top: Radius.circular(24),
//               ),
//             ),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Container(
//                   width: 40,
//                   height: 4,
//                   decoration: BoxDecoration(
//                     color: AppColors.textHint,
//                     borderRadius: BorderRadius.circular(2),
//                   ),
//                 ),
//                 const SizedBox(height: 16),
//                 Text(
//                   'Choisir une photo',
//                   style: TextStyle(
//                     color: AppColors.textPrimary,
//                     fontWeight: FontWeight.w700,
//                     fontSize: 16,
//                   ),
//                 ),
//                 const SizedBox(height: 20),
//                 _imageSourceOption(
//                   icon: Icons.photo_library_outlined,
//                   iconColor: AppColors.accent,
//                   iconBg: AppColors.accentLight,
//                   label: 'Choisir depuis la galerie',
//                   onTap: () {
//                     Navigator.pop(context);
//                     _pickImage(ImageSource.gallery);
//                   },
//                 ),
//                 const SizedBox(height: 12),
//                 _imageSourceOption(
//                   icon: Icons.camera_alt_outlined,
//                   iconColor: AppColors.green,
//                   iconBg: const Color(0x1539B54A),
//                   label: 'Prendre une photo',
//                   onTap: () {
//                     Navigator.pop(context);
//                     _pickImage(ImageSource.camera);
//                   },
//                 ),
//               ],
//             ),
//           ),
//     );
//   }

//   Widget _imageSourceOption({
//     required IconData icon,
//     required Color iconColor,
//     required Color iconBg,
//     required String label,
//     required VoidCallback onTap,
//   }) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
//         decoration: BoxDecoration(
//           color: AppColors.surfaceAlt,
//           borderRadius: BorderRadius.circular(14),
//           border: Border.all(
//             color: AppColors.textHint.withOpacity(0.3),
//             width: 1.5,
//           ),
//         ),
//         child: Row(
//           children: [
//             Container(
//               width: 42,
//               height: 42,
//               decoration: BoxDecoration(
//                 color: iconBg,
//                 borderRadius: BorderRadius.circular(10),
//               ),
//               child: Icon(icon, color: iconColor, size: 20),
//             ),
//             const SizedBox(width: 14),
//             Text(
//               label,
//               style: TextStyle(
//                 color: AppColors.textPrimary,
//                 fontWeight: FontWeight.w600,
//                 fontSize: 14,
//               ),
//             ),
//             const Spacer(),
//             Icon(
//               Icons.chevron_right_rounded,
//               color: AppColors.textHint,
//               size: 18,
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // ── Dropdown catégorie ──
//   Widget _buildCategoryGrid() {
//     return Container(
//       decoration: BoxDecoration(
//         color: AppColors.background,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(
//           color:
//               _selectedCategory != null
//                   ? AppColors.accent
//                   : AppColors.textHint.withOpacity(0.4),
//           width: 1.5,
//         ),
//       ),
//       padding: const EdgeInsets.symmetric(horizontal: 14),
//       child: DropdownButtonHideUnderline(
//         child: DropdownButton<ProductCategory>(
//           value: _selectedCategory,
//           isExpanded: true,
//           icon: const Icon(
//             Icons.keyboard_arrow_down_rounded,
//             color: AppColors.accent,
//             size: 22,
//           ),
//           hint: Text(
//             'Sélectionner une catégorie',
//             style: TextStyle(color: AppColors.textHint, fontSize: 14),
//           ),
//           style: TextStyle(
//             color: AppColors.textPrimary,
//             fontSize: 14,
//             fontWeight: FontWeight.w500,
//           ),
//           dropdownColor: AppColors.surface,
//           borderRadius: BorderRadius.circular(14),
//           onChanged: (cat) => setState(() => _selectedCategory = cat),
//           items:
//               ProductCategory.values.map((cat) {
//                 return DropdownMenuItem<ProductCategory>(
//                   value: cat,
//                   child: Text(
//                     cat.label,
//                     style: TextStyle(
//                       color: AppColors.textPrimary,
//                       fontSize: 14,
//                     ),
//                   ),
//                 );
//               }).toList(),
//         ),
//       ),
//     );
//   }

//   // ── Champ description multi-lignes ──
//   Widget _buildDescriptionField() {
//     return Container(
//       decoration: BoxDecoration(
//         color: AppColors.background,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(
//           color: AppColors.textHint.withOpacity(0.4),
//           width: 1.5,
//         ),
//       ),
//       padding: const EdgeInsets.symmetric(horizontal: 14),
//       child: TextField(
//         controller: _descriptionCtrl,
//         maxLines: 4,
//         style: TextStyle(color: AppColors.textPrimary, fontSize: 14),
//         decoration: InputDecoration(
//           hintText: 'Ajouter une description (optionnel)',
//           hintStyle: TextStyle(color: AppColors.textHint, fontSize: 13),
//           border: InputBorder.none,
//           contentPadding: const EdgeInsets.symmetric(vertical: 12),
//         ),
//       ),
//     );
//   }

//   // ── Sélection acheteurs autorisés ──
//   Widget _buildBuyerSelection() {
//     return Column(
//       children: [
//         _buyerCheckbox(BuyerType.professionnel),
//         const SizedBox(height: 10),
//         _buyerCheckbox(BuyerType.autre),
//       ],
//     );
//   }

//   Widget _buyerCheckbox(BuyerType type) {
//     return GestureDetector(
//       onTap: () {
//         setState(() {
//           if (_selectedBuyers.contains(type)) {
//             _selectedBuyers.remove(type);
//           } else {
//             _selectedBuyers.add(type);
//           }
//         });
//       },
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
//         decoration: BoxDecoration(
//           color:
//               _selectedBuyers.contains(type)
//                   ? AppColors.primaryLight
//                   : AppColors.background,
//           borderRadius: BorderRadius.circular(12),
//           border: Border.all(
//             color:
//                 _selectedBuyers.contains(type)
//                     ? AppColors.primary
//                     : AppColors.textHint.withOpacity(0.4),
//             width: 1.5,
//           ),
//         ),
//         child: Row(
//           children: [
//             Container(
//               width: 20,
//               height: 20,
//               decoration: BoxDecoration(
//                 color:
//                     _selectedBuyers.contains(type)
//                         ? AppColors.primary
//                         : Colors.transparent,
//                 borderRadius: BorderRadius.circular(4),
//                 border: Border.all(
//                   color:
//                       _selectedBuyers.contains(type)
//                           ? AppColors.primary
//                           : AppColors.textHint,
//                   width: 2,
//                 ),
//               ),
//               child:
//                   _selectedBuyers.contains(type)
//                       ? const Icon(
//                         Icons.check_rounded,
//                         color: Colors.white,
//                         size: 14,
//                       )
//                       : null,
//             ),
//             const SizedBox(width: 12),
//             Text(
//               type.label,
//               style: TextStyle(
//                 color: AppColors.textPrimary,
//                 fontWeight:
//                     _selectedBuyers.contains(type)
//                         ? FontWeight.w700
//                         : FontWeight.w500,
//                 fontSize: 14,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // ── Barre de boutons en bas ──
//   Widget _buildBottomBar() {
//     return Container(
//       padding: EdgeInsets.fromLTRB(
//         20,
//         16,
//         20,
//         MediaQuery.of(context).padding.bottom + 16,
//       ),
//       decoration: BoxDecoration(
//         color: AppColors.surface,
//         boxShadow: [
//           BoxShadow(
//             color: AppColors.shadowDeep,
//             blurRadius: 20,
//             offset: const Offset(0, -4),
//           ),
//         ],
//       ),
//       child: Row(
//         children: [
//           // Bouton Annuler
//           Expanded(
//             child: OutlinedButton(
//               onPressed: _isLoading ? null : () => Navigator.pop(context),
//               style: OutlinedButton.styleFrom(
//                 padding: const EdgeInsets.symmetric(vertical: 14),
//                 side: BorderSide(
//                   color: AppColors.textHint.withOpacity(0.4),
//                   width: 1.5,
//                 ),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//               ),
//               child: Text(
//                 'Annuler',
//                 style: TextStyle(
//                   color: AppColors.textSecondary,
//                   fontWeight: FontWeight.w700,
//                   fontSize: 14,
//                 ),
//               ),
//             ),
//           ),
//           const SizedBox(width: 12),
//           // Bouton Ajouter
//           Expanded(
//             child: ElevatedButton(
//               onPressed: _isLoading ? null : _submit,
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: AppColors.primary,
//                 disabledBackgroundColor: AppColors.primary.withOpacity(0.5),
//                 foregroundColor: Colors.white,
//                 padding: const EdgeInsets.symmetric(vertical: 14),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 elevation: 0,
//               ),
//               child:
//                   _isLoading
//                       ? SizedBox(
//                         height: 20,
//                         width: 20,
//                         child: CircularProgressIndicator(
//                           valueColor: AlwaysStoppedAnimation<Color>(
//                             Colors.white,
//                           ),
//                           strokeWidth: 2,
//                         ),
//                       )
//                       : const Text(
//                         'Ajouter',
//                         style: TextStyle(
//                           fontWeight: FontWeight.w700,
//                           fontSize: 14,
//                         ),
//                       ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import '../../model/product.dart';
import '../../services/product_service.dart';
import '../../style/theme/colors.dart';
import '../../utils/app_validators.dart';
import '../../widgets/app_text_field.dart';

class AddProductPage extends StatefulWidget {
  const AddProductPage({super.key, required this.onProductAdded});

  final void Function(Product product) onProductAdded;

  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final _nameCtrl = TextEditingController();
  final _brandCtrl = TextEditingController();
  final _quantityCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();

  ProductCategory? _selectedCategory;
  final Set<BuyerType> _selectedBuyers = {};
  XFile? _pickedImage;
  final _picker = ImagePicker();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _brandCtrl.dispose();
    _quantityCtrl.dispose();
    _priceCtrl.dispose();
    _descriptionCtrl.dispose();
    super.dispose();
  }

  // ── Validation et soumission ──
  void _submit() async {
    final name = _nameCtrl.text.trim();
    final brand = _brandCtrl.text.trim();
    final quantityStr = _quantityCtrl.text.trim();
    final priceStr = _priceCtrl.text.trim();
    final description = _descriptionCtrl.text.trim();

    // Validations
    final nameError = AppValidators.name(name);
    if (nameError != null) {
      _showError(nameError);
      return;
    }

    final brandError = AppValidators.name(brand);
    if (brandError != null) {
      _showError('Marque : $brandError');
      return;
    }

    if (_selectedCategory == null) {
      _showError('Veuillez sélectionner une catégorie.');
      return;
    }

    final quantity = int.tryParse(quantityStr);
    if (quantityStr.isEmpty || quantity == null || quantity < 0) {
      _showError('Quantité invalide.');
      return;
    }

    final price = double.tryParse(priceStr.replaceAll(',', '.'));
    if (priceStr.isEmpty || price == null || price <= 0) {
      _showError('Prix invalide.');
      return;
    }

    if (_selectedBuyers.isEmpty) {
      _showError('Sélectionnez au moins un type d\'acheteur autorisé.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Préparer les bytes de l'image si elle existe
      Uint8List? imageBytes;
      String? imageFileName;

      if (_pickedImage != null) {
        imageBytes = await _pickedImage!.readAsBytes();
        imageFileName = _pickedImage!.name;
      }

      // ✅ APPEL CORRECT À FIREBASE AVEC LES PARAMÈTRES NOMMÉS
      final newProduct = await ProductService.addProduct(
        Product(
          id: '',
          name: name,
          brand: brand,
          category: _selectedCategory!,
          quantity: quantity,
          price: price,
          description: description,
          allowedBuyers: _selectedBuyers.toList(),
          imagePath: null,
        ),
        nom: name,
        marque: brand,
        category: _selectedCategory!,
        prix: price,
        quantite: quantity,
        description: description,
        acheteurs: _selectedBuyers.toList(),
        imageBytes: imageBytes,
        imageFileName: imageFileName,
      );

      if (!mounted) return;

      kProducts.add(newProduct);
      widget.onProductAdded(newProduct);

      setState(() => _isLoading = false);
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(
                Icons.check_circle_outline_rounded,
                color: Colors.white,
              ),
              const SizedBox(width: 10),
              Flexible(child: Text('« $name » ajouté au catalogue !')),
            ],
          ),
          backgroundColor: AppColors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 3),
        ),
      );
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        //  Message spécifique si produit existe déjà
        if (e.toString().contains('existe déjà')) {
          _showError('Ce produit existe déjà dans le catalogue.');
        } else {
          _showError('Erreur lors de l\'ajout du produit: $e');
        }
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFFD32F2F),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: isMobile ? _buildAppBar() : null,
      body: isMobile ? _buildBody() : _buildWebBody(),
      bottomNavigationBar: isMobile ? _buildBottomBar() : null,
    );
  }

  // ── Web Body - Layout responsive ──
  Widget _buildWebBody() {
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            color: AppColors.surface,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_rounded),
                  onPressed: () => Navigator.pop(context),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Nouveau produit',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Ajouter un nouveau produit au catalogue',
                      style: TextStyle(fontSize: 13, color: Color(0xFF999999)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1000),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 2, child: _buildWebFormSection()),
                  const SizedBox(width: 32),
                  Expanded(child: _buildWebPreviewSection()),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Web Form Section ──
  Widget _buildWebFormSection() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Photo du produit', Icons.photo_camera_outlined),
          const SizedBox(height: 14),
          _buildImagePicker(),
          const SizedBox(height: 32),
          _sectionTitle('Informations générales', Icons.info_outline_rounded),
          const SizedBox(height: 14),
          AppTextField(
            controller: _nameCtrl,
            label: 'Nom du produit *',
            hint: 'Ex: Détartreuse ultrasonique',
            icon: Icons.inventory_2_outlined,
            inputFormatters: [
              TextInputFormatter.withFunction(
                (oldValue, newValue) =>
                    newValue.copyWith(text: newValue.text.toUpperCase()),
              ),
            ],
          ),
          const SizedBox(height: 12),
          AppTextField(
            controller: _brandCtrl,
            label: 'Marque',
            hint: 'Ex: Cavitron',
            icon: Icons.local_shipping_outlined,
          ),
          const SizedBox(height: 12),
          AppTextField(
            controller: _descriptionCtrl,
            label: 'Description',
            hint: 'Description détaillée du produit...',
            icon: Icons.description_outlined,
            maxLines: 4,
          ),
          const SizedBox(height: 32),
          _sectionTitle('Prix & Quantité', Icons.price_check_rounded),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: AppTextField(
                  controller: _priceCtrl,
                  label: 'Prix (DA)',
                  hint: '0.00',
                  icon: Icons.currency_exchange_rounded,
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AppTextField(
                  controller: _quantityCtrl,
                  label: 'Quantité',
                  hint: '0',
                  icon: Icons.inventory_rounded,
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          _sectionTitle('Catégorie', Icons.category_outlined),
          const SizedBox(height: 14),
          _buildCategoryDropdown(),
        ],
      ),
    );
  }

  // ── Web Preview Section ──
  Widget _buildWebPreviewSection() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadow,
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Aperçu',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 16),
                if (_pickedImage != null)
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child:
                        kIsWeb
                            ? Image.network(_pickedImage!.path)
                            : Image.file(File(_pickedImage!.path)),
                  )
                else
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Icon(Icons.image_outlined, size: 48),
                    ),
                  ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 16),
                _buildBuyerSelection(),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: FilledButton(
                    onPressed: _isLoading ? null : _submit,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child:
                        _isLoading
                            ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation(
                                  Colors.white,
                                ),
                              ),
                            )
                            : const Text(
                              'Ajouter le produit',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                              ),
                            ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── AppBar ──
  PreferredSizeWidget _buildAppBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(kToolbarHeight),
      child: Container(
        decoration: BoxDecoration(
          gradient: AppColors.appBarGradient,
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowDeep,
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(
              Icons.close_rounded,
              color: Colors.white,
              size: 22,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Nouveau produit',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 17,
                ),
              ),
              Text(
                'Remplir les informations',
                style: TextStyle(color: Color(0xAAFFFFFF), fontSize: 10),
              ),
            ],
          ),
          centerTitle: true,
        ),
      ),
    );
  }

  // ── Body ──
  Widget _buildBody() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Photo du produit ──
          _sectionTitle('Photo du produit', Icons.photo_camera_outlined),
          const SizedBox(height: 14),
          _buildImagePicker(),
          const SizedBox(height: 24),

          // ── Section Informations générales ──
          _sectionTitle('Informations générales', Icons.info_outline_rounded),
          const SizedBox(height: 14),
          AppTextField(
            controller: _nameCtrl,
            label: 'Nom du produit *',
            icon: Icons.inventory_2_outlined,
            inputFormatters: AppFormatters.name,
          ),
          const SizedBox(height: 14),
          AppTextField(
            controller: _brandCtrl,
            label: 'Marque *',
            icon: Icons.branding_watermark_outlined,
            inputFormatters: AppFormatters.name,
          ),
          const SizedBox(height: 14),

          // ── Catégorie ──
          _sectionTitle('Catégorie *', Icons.category_outlined),
          const SizedBox(height: 10),
          _buildCategoryGrid(),
          const SizedBox(height: 24),

          // ── Stock & Prix ──
          _sectionTitle('Stock & Prix', Icons.monetization_on_outlined),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: AppTextField(
                  controller: _quantityCtrl,
                  label: 'Quantité *',
                  icon: Icons.layers_outlined,
                  keyboardType: TextInputType.number,
                  inputFormatters: AppFormatters.digitsOnly,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: AppTextField(
                  controller: _priceCtrl,
                  label: 'Prix (DA) *',
                  icon: Icons.sell_outlined,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // ── Description ──
          _sectionTitle('Description', Icons.description_outlined),
          const SizedBox(height: 14),
          _buildDescriptionField(),
          const SizedBox(height: 24),

          // ── Acheteurs autorisés ──
          _sectionTitle('Acheteurs autorisés *', Icons.people_outline_rounded),
          const SizedBox(height: 4),
          Text(
            'Qui a le droit d\'acheter ce produit ?',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
          ),
          const SizedBox(height: 12),
          _buildBuyerSelection(),
        ],
      ),
    );
  }

  // ── Titre de section ──
  Widget _sectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppColors.primary, size: 18),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 15,
          ),
        ),
      ],
    );
  }

  // ── Sélecteur de photo ──
  Future<void> _pickImage(ImageSource source) async {
    try {
      final picked = await _picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 800,
      );
      if (picked != null) setState(() => _pickedImage = picked);
    } catch (_) {
      _showError('Impossible d\'accéder à la galerie/caméra.');
    }
  }

  Widget _buildImagePicker() {
    return GestureDetector(
      onTap: () => _showImageSourceDialog(),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: double.infinity,
        height: 180,
        decoration: BoxDecoration(
          color: AppColors.surfaceAlt,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color:
                _pickedImage != null
                    ? AppColors.accent
                    : AppColors.textHint.withOpacity(0.4),
            width: _pickedImage != null ? 2 : 1.5,
            style: _pickedImage != null ? BorderStyle.solid : BorderStyle.solid,
          ),
        ),
        child:
            _pickedImage != null
                ? _buildImagePreview()
                : _buildImagePlaceholder(),
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: AppColors.accentLight,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(
            Icons.add_photo_alternate_outlined,
            color: AppColors.accent,
            size: 28,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Ajouter une photo',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Appuyez pour choisir depuis la galerie ou la caméra',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.textMuted, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildImagePreview() {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Image
        ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child:
              kIsWeb
                  ? Image.network(_pickedImage!.path, fit: BoxFit.cover)
                  : Image.file(File(_pickedImage!.path), fit: BoxFit.cover),
        ),
        // Overlay sombre en bas
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(14),
                bottomRight: Radius.circular(14),
              ),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black.withOpacity(0.55)],
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Photo sélectionnée',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                GestureDetector(
                  onTap: () => _showImageSourceDialog(),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Changer',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        // Bouton supprimer
        Positioned(
          top: 8,
          right: 8,
          child: GestureDetector(
            onTap: () => setState(() => _pickedImage = null),
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.close_rounded,
                color: Colors.white,
                size: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder:
          (_) => Container(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.textHint,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Choisir une photo',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 20),
                _imageSourceOption(
                  icon: Icons.photo_library_outlined,
                  iconColor: AppColors.accent,
                  iconBg: AppColors.accentLight,
                  label: 'Choisir depuis la galerie',
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.gallery);
                  },
                ),
                const SizedBox(height: 12),
                _imageSourceOption(
                  icon: Icons.camera_alt_outlined,
                  iconColor: AppColors.green,
                  iconBg: const Color(0x1539B54A),
                  label: 'Prendre une photo',
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.camera);
                  },
                ),
              ],
            ),
          ),
    );
  }

  Widget _imageSourceOption({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surfaceAlt,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: AppColors.textHint.withOpacity(0.3),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 14),
            Text(
              label,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            const Spacer(),
            Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textHint,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  // ── Dropdown catégorie ──
  Widget _buildCategoryGrid() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              _selectedCategory != null
                  ? AppColors.accent
                  : AppColors.textHint.withOpacity(0.4),
          width: 1.5,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<ProductCategory>(
          value: _selectedCategory,
          isExpanded: true,
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: AppColors.accent,
            size: 22,
          ),
          hint: Text(
            'Sélectionner une catégorie',
            style: TextStyle(color: AppColors.textHint, fontSize: 14),
          ),
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          dropdownColor: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          onChanged: (cat) => setState(() => _selectedCategory = cat),
          items:
              ProductCategory.values.map((cat) {
                return DropdownMenuItem<ProductCategory>(
                  value: cat,
                  child: Text(
                    cat.label,
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                    ),
                  ),
                );
              }).toList(),
        ),
      ),
    );
  }

  // ── Champ description multi-lignes ──
  Widget _buildDescriptionField() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.textHint.withOpacity(0.4),
          width: 1.5,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: TextField(
        controller: _descriptionCtrl,
        maxLines: 4,
        style: TextStyle(color: AppColors.textPrimary, fontSize: 14),
        decoration: InputDecoration(
          hintText: 'Ajouter une description (optionnel)',
          hintStyle: TextStyle(color: AppColors.textHint, fontSize: 13),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  // ── Sélection acheteurs autorisés ──
  Widget _buildBuyerSelection() {
    return Column(
      children: [
        _buyerCheckbox(BuyerType.professionnel),
        const SizedBox(height: 10),
        _buyerCheckbox(BuyerType.autre),
      ],
    );
  }

  Widget _buyerCheckbox(BuyerType type) {
    return GestureDetector(
      onTap: () {
        setState(() {
          if (_selectedBuyers.contains(type)) {
            _selectedBuyers.remove(type);
          } else {
            _selectedBuyers.add(type);
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color:
              _selectedBuyers.contains(type)
                  ? AppColors.primaryLight
                  : AppColors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color:
                _selectedBuyers.contains(type)
                    ? AppColors.primary
                    : AppColors.textHint.withOpacity(0.4),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color:
                    _selectedBuyers.contains(type)
                        ? AppColors.primary
                        : Colors.transparent,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color:
                      _selectedBuyers.contains(type)
                          ? AppColors.primary
                          : AppColors.textHint,
                  width: 2,
                ),
              ),
              child:
                  _selectedBuyers.contains(type)
                      ? const Icon(
                        Icons.check_rounded,
                        color: Colors.white,
                        size: 14,
                      )
                      : null,
            ),
            const SizedBox(width: 12),
            Text(
              type.label,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight:
                    _selectedBuyers.contains(type)
                        ? FontWeight.w700
                        : FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Barre de boutons en bas ──
  Widget _buildBottomBar() {
    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        16,
        20,
        MediaQuery.of(context).padding.bottom + 16,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowDeep,
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Bouton Annuler
          Expanded(
            child: OutlinedButton(
              onPressed: _isLoading ? null : () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: BorderSide(
                  color: AppColors.textHint.withOpacity(0.4),
                  width: 1.5,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Annuler',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Bouton Ajouter
          Expanded(
            child: ElevatedButton(
              onPressed: _isLoading ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                disabledBackgroundColor: AppColors.primary.withOpacity(0.5),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child:
                  _isLoading
                      ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                          strokeWidth: 2,
                        ),
                      )
                      : const Text(
                        'Ajouter',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              _selectedCategory != null
                  ? AppColors.primary
                  : const Color(0xFFE5E7EB),
          width: 1.5,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<ProductCategory>(
          value: _selectedCategory,
          isExpanded: true,
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: AppColors.primary,
            size: 22,
          ),
          hint: const Text(
            'Sélectionner une catégorie',
            style: TextStyle(fontSize: 14),
          ),
          onChanged: (cat) => setState(() => _selectedCategory = cat),
          items:
              ProductCategory.values.map((cat) {
                return DropdownMenuItem<ProductCategory>(
                  value: cat,
                  child: Text(cat.label, style: const TextStyle(fontSize: 14)),
                );
              }).toList(),
        ),
      ),
    );
  }
}
