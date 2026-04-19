import 'package:flutter/material.dart';
import '../style/constants/app_colors.dart';
import '../style/constants/app_dimens.dart';


/// Carte d'information affichée dans la barre du bas du banner
/// Ex : téléphone, email, disponibilité
class InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;   // label en dessous (ex: "APPELEZ-NOUS")
  final String text;    // valeur principale (ex: "07 82 58 00 55")
  final bool isMobile;

  const InfoCard({
    super.key,
    required this.icon,
    required this.title,
    required this.text,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile
            ? AppDimens.infoCardPadHMobile
            : AppDimens.infoCardPadH,
        vertical: isMobile
            ? AppDimens.infoCardPadVMobile
            : AppDimens.infoCardPadV,
      ),
      decoration: BoxDecoration(
        color: AppColors.infoCardBg,
        border: Border.all(color: AppColors.infoCardBorder, width: 0.5),
      ),
      child: Row(
        children: [
          _buildIcon(),
          SizedBox(width: isMobile ? 12 : 16),
          Expanded(child: _buildTexts()),
        ],
      ),
    );
  }

  Widget _buildIcon() {
    return Container(
      width:  isMobile ? AppDimens.infoIconSizeMobile  : AppDimens.infoIconSize,
      height: isMobile ? AppDimens.infoIconSizeMobile  : AppDimens.infoIconSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.infoIconBorder, width: 1.5),
      ),
      child: Icon(
        icon,
        color: AppColors.infoIconColor,
        size: isMobile ? AppDimens.infoIconInnerMobile : AppDimens.infoIconInner,
      ),
    );
  }

  Widget _buildTexts() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          text,
          style: TextStyle(
            fontSize: isMobile
                ? AppDimens.fontInfoTitleMobile
                : AppDimens.fontInfoTitle,
            fontWeight: FontWeight.w600,
            color: AppColors.infoTitle,
          ),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
        const SizedBox(height: 3),
        Text(
          title.toUpperCase(),
          style: const TextStyle(
            fontSize: AppDimens.fontInfoLabel,
            color: AppColors.infoLabel,
            letterSpacing: 0.8,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}