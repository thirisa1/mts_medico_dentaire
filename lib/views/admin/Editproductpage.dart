import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../../services/product_service.dart' show ProductService;
import '../../model/product.dart';
import '../../style/theme/colors.dart';
import '../../widgets/app_text_field.dart';

// ─────────────────────────────────────────────
// Page Modifier un produit
// ─────────────────────────────────────────────
class EditProductPage extends StatefulWidget {
  const EditProductPage({
    super.key,
    required this.product,
    required this.onProductUpdated,
  });

  final Product product;
  final void Function(Product updated) onProductUpdated;

  @override
  State<EditProductPage> createState() => _EditProductPageState();
}

class _EditProductPageState extends State<EditProductPage> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _brandCtrl;
  late final TextEditingController _quantityCtrl;
  late final TextEditingController _priceCtrl;
  late final TextEditingController _descriptionCtrl;

  late ProductCategory? _selectedCategory;
  late Set<BuyerType> _selectedBuyers;

  XFile? _newImage; // nouvelle image choisie
  bool _isLoading = false;
  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    // Pré-remplir avec les données existantes
    final p = widget.product;
    _nameCtrl = TextEditingController(text: p.name);
    _brandCtrl = TextEditingController(text: p.brand);
    _quantityCtrl = TextEditingController(text: p.quantity.toString());
    _priceCtrl = TextEditingController(text: p.price.toStringAsFixed(0));
    _descriptionCtrl = TextEditingController(text: p.description);
    _selectedCategory = p.category;
    _selectedBuyers = Set<BuyerType>.from(p.allowedBuyers);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _brandCtrl.dispose();
    _quantityCtrl.dispose();
    _priceCtrl.dispose();
    _descriptionCtrl.dispose();
    super.dispose();
  }

  // ── Validation ──
  String? _validate() {
    if (_nameCtrl.text.trim().isEmpty) return 'Nom requis.';
    if (_brandCtrl.text.trim().isEmpty) return 'Marque requise.';
    if (_selectedCategory == null) {
      return 'Veuillez sélectionner une catégorie.';
    }
    final qty = int.tryParse(_quantityCtrl.text.trim());
    if (qty == null || qty < 0) return 'Quantité invalide.';
    final price = double.tryParse(_priceCtrl.text.trim().replaceAll(',', '.'));
    if (price == null || price <= 0) return 'Prix invalide.';
    if (_selectedBuyers.isEmpty) return 'Sélectionnez au moins un acheteur.';
    return null;
  }

  // ── Soumission ──
  Future<void> _submit() async {
    final error = _validate();
    if (error != null) {
      _showError(error);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final imageBytes =
          _newImage != null ? await _newImage!.readAsBytes() : null;

      final updated = await ProductService.updateProduct(
        productId: widget.product.id,
        nom: _nameCtrl.text.trim(),
        marque: _brandCtrl.text.trim(),
        category: _selectedCategory!,
        prix: double.parse(_priceCtrl.text.trim().replaceAll(',', '.')),
        quantite: int.parse(_quantityCtrl.text.trim()),
        description: _descriptionCtrl.text.trim(),
        acheteurs: _selectedBuyers.toList(),
        newImageBytes: imageBytes,
        newImageFileName: _newImage?.name,
        existingImageUrl: widget.product.imagePath,
      );

      widget.onProductUpdated(updated);

      if (!mounted) return;
      Navigator.pop(context, updated);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(
                Icons.check_circle_outline_rounded,
                color: Colors.white,
              ),
              const SizedBox(width: 10),
              Flexible(child: Text('« ${updated.name} » mis à jour !')),
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
        if (e.toString().contains('existe déjà')) {
          _showError('Un produit avec ce nom existe déjà dans le catalogue.');
        } else {
          _showError('Erreur lors de la mise à jour : $e');
        }
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: const Color(0xFFD32F2F),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  // ── Sélectionner une image ──
  Future<void> _pickImage(ImageSource source) async {
    try {
      final picked = await _picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 800,
      );
      if (picked != null) setState(() => _newImage = picked);
    } catch (_) {
      _showError('Impossible d\'accéder à la galerie/caméra.');
    }
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
                  'Changer la photo',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 20),
                _sourceOption(
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
                _sourceOption(
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

  Widget _sourceOption({
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
          color: AppColors.background,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: AppColors.textHint.withValues(alpha: 0.3),
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

  // ─────────────────────────────────────────────
  // BUILD
  // ─────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: AppColors.primary),
              const SizedBox(height: 16),
              Text(
                'Mise à jour en cours...',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: isMobile ? _buildAppBar() : null,
      body: isMobile ? _buildMobileBody() : _buildWebBody(),
      bottomNavigationBar: isMobile ? _buildBottomBar() : null,
    );
  }

  // ── Mobile Body ──
  Widget _buildMobileBody() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Photo du produit', Icons.photo_camera_outlined),
          const SizedBox(height: 14),
          _buildImagePicker(),
          const SizedBox(height: 24),
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
          const SizedBox(height: 14),
          AppTextField(
            controller: _brandCtrl,
            label: 'Marque *',
            hint: 'Ex: Cavitron',
            icon: Icons.branding_watermark_outlined,
          ),
          const SizedBox(height: 24),
          _sectionTitle('Catégorie *', Icons.category_outlined),
          const SizedBox(height: 10),
          _buildCategoryDropdown(),
          const SizedBox(height: 24),
          _sectionTitle('Stock & Prix', Icons.monetization_on_outlined),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: AppTextField(
                  controller: _quantityCtrl,
                  label: 'Quantité *',
                  hint: '0',
                  icon: Icons.layers_outlined,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: AppTextField(
                  controller: _priceCtrl,
                  label: 'Prix (DA) *',
                  hint: '0.00',
                  icon: Icons.sell_outlined,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _sectionTitle('Description', Icons.description_outlined),
          const SizedBox(height: 14),
          _buildDescriptionField(),
          const SizedBox(height: 24),
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

  // ── Web Body ──
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
                      'Modifier le produit',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Mettre à jour les informations du produit',
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
                  Expanded(
                    flex: 2,
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _sectionTitle(
                            'Photo du produit',
                            Icons.photo_camera_outlined,
                          ),
                          const SizedBox(height: 14),
                          _buildImagePicker(),
                          const SizedBox(height: 32),
                          _sectionTitle(
                            'Informations générales',
                            Icons.info_outline_rounded,
                          ),
                          const SizedBox(height: 14),
                          AppTextField(
                            controller: _nameCtrl,
                            label: 'Nom du produit *',
                            hint: 'Ex: Détartreuse ultrasonique',
                            icon: Icons.inventory_2_outlined,
                            inputFormatters: [
                              TextInputFormatter.withFunction(
                                (oldValue, newValue) => newValue.copyWith(
                                  text: newValue.text.toUpperCase(),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          AppTextField(
                            controller: _brandCtrl,
                            label: 'Marque *',
                            hint: 'Ex: Cavitron',
                            icon: Icons.branding_watermark_outlined,
                          ),
                          const SizedBox(height: 24),
                          _sectionTitle('Catégorie *', Icons.category_outlined),
                          const SizedBox(height: 10),
                          _buildCategoryDropdown(),
                          const SizedBox(height: 24),
                          _sectionTitle(
                            'Description',
                            Icons.description_outlined,
                          ),
                          const SizedBox(height: 14),
                          _buildDescriptionField(),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 32),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
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
                                  'Stock & Prix',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                AppTextField(
                                  controller: _quantityCtrl,
                                  label: 'Quantité *',
                                  hint: '0',
                                  icon: Icons.layers_outlined,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],
                                ),
                                const SizedBox(height: 14),
                                AppTextField(
                                  controller: _priceCtrl,
                                  label: 'Prix (DA) *',
                                  hint: '0.00',
                                  icon: Icons.sell_outlined,
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                        decimal: true,
                                      ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
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
                                  'Acheteurs autorisés *',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Qui a le droit d\'acheter ce produit ?',
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                _buildBuyerSelection(),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            height: 52,
                            child: FilledButton(
                              onPressed: _submit,
                              style: FilledButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                'Mettre à jour',
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
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

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
                'Modifier le produit',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 17,
                ),
              ),
              Text(
                'Mettre à jour les informations',
                style: TextStyle(color: Color(0xAAFFFFFF), fontSize: 10),
              ),
            ],
          ),
          centerTitle: true,
        ),
      ),
    );
  }

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

  // ── Aperçu image ──
  Widget _buildImagePicker() {
    // Priorité : nouvelle image > image existante > placeholder
    final hasNew = _newImage != null;
    final hasExisting =
        widget.product.imagePath != null &&
        widget.product.imagePath!.isNotEmpty;

    return GestureDetector(
      onTap: _showImageSourceDialog,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: double.infinity,
        height: 180,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color:
                (hasNew || hasExisting)
                    ? AppColors.accent
                    : AppColors.textHint.withValues(alpha: 0.4),
            width: (hasNew || hasExisting) ? 2 : 1.5,
          ),
        ),
        child:
            hasNew
                ? _imagePreview(
                  child:
                      kIsWeb
                          ? Image.network(_newImage!.path, fit: BoxFit.cover)
                          : Image.file(
                            File(_newImage!.path),
                            fit: BoxFit.cover,
                          ),
                )
                : hasExisting
                ? _imagePreview(
                  child: Image.network(
                    widget.product.imagePath!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _imagePlaceholder(),
                  ),
                )
                : _imagePlaceholder(),
      ),
    );
  }

  Widget _imagePreview({required Widget child}) {
    return Stack(
      fit: StackFit.expand,
      children: [
        ClipRRect(borderRadius: BorderRadius.circular(14), child: child),
        Positioned(
          bottom: 8,
          right: 8,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.55),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.edit_outlined, color: Colors.white, size: 14),
                SizedBox(width: 5),
                Text(
                  'Changer',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _imagePlaceholder() {
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
          'Appuyez pour choisir',
          style: TextStyle(color: AppColors.textMuted, fontSize: 12),
        ),
      ],
    );
  }

  // ── Dropdown catégorie ──
  Widget _buildCategoryDropdown() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              _selectedCategory != null
                  ? AppColors.accent
                  : AppColors.textHint.withValues(alpha: 0.4),
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
              ProductCategory.values
                  .map(
                    (cat) => DropdownMenuItem(
                      value: cat,
                      child: Text(
                        cat.label,
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  )
                  .toList(),
        ),
      ),
    );
  }

  // ── Description ──
  Widget _buildDescriptionField() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _descriptionCtrl,
        maxLines: 4,
        style: TextStyle(color: AppColors.textPrimary, fontSize: 14),
        decoration: InputDecoration(
          hintText: 'Description du produit (optionnel)...',
          hintStyle: TextStyle(color: AppColors.textHint, fontSize: 13),
          filled: true,
          fillColor: AppColors.background,
          contentPadding: const EdgeInsets.all(16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
          ),
        ),
      ),
    );
  }

  // ── Acheteurs ──
  Widget _buildBuyerSelection() {
    return Row(
      children:
          BuyerType.values.map((type) {
            final isSelected = _selectedBuyers.contains(type);
            final color = _buyerColor(type);
            return Expanded(
              child: GestureDetector(
                onTap:
                    () => setState(() {
                      isSelected
                          ? _selectedBuyers.remove(type)
                          : _selectedBuyers.add(type);
                    }),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: EdgeInsets.only(
                    right: type != BuyerType.values.last ? 10 : 0,
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color:
                        isSelected
                            ? color.withValues(alpha: 0.12)
                            : AppColors.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected ? color : AppColors.background,
                      width: isSelected ? 2 : 1.5,
                    ),
                    boxShadow:
                        isSelected
                            ? [
                              BoxShadow(
                                color: color.withValues(alpha: 0.2),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ]
                            : null,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _buyerIcon(type),
                        color: isSelected ? color : AppColors.textHint,
                        size: 26,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        type.label,
                        style: TextStyle(
                          color: isSelected ? color : AppColors.textSecondary,
                          fontSize: 12,
                          fontWeight:
                              isSelected ? FontWeight.w700 : FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: isSelected ? color : Colors.transparent,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: isSelected ? color : AppColors.textHint,
                            width: 1.5,
                          ),
                        ),
                        child:
                            isSelected
                                ? const Icon(
                                  Icons.check_rounded,
                                  color: Colors.white,
                                  size: 13,
                                )
                                : null,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
    );
  }

  Color _buyerColor(BuyerType type) {
    switch (type) {
      case BuyerType.professionnel:
        return AppColors.accent;
      case BuyerType.autre:
        return AppColors.green;
    }
  }

  IconData _buyerIcon(BuyerType type) {
    switch (type) {
      case BuyerType.professionnel:
        return Icons.medical_services_outlined;
      case BuyerType.autre:
        return Icons.person_outline_rounded;
    }
  }

  // ── Bouton Enregistrer ──
  Widget _buildBottomBar() {
    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        12,
        20,
        MediaQuery.of(context).padding.bottom + 12,
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
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _isLoading ? null : _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 0,
            disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.5),
          ),
          child:
              _isLoading
                  ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  )
                  : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.save_outlined, size: 20),
                      SizedBox(width: 10),
                      Text(
                        'Enregistrer les modifications',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
        ),
      ),
    );
  }
}
