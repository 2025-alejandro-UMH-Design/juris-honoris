import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';

/// Modelo local para datos de abogado (mock).
class LawyerData {
  final String id;
  final String name;
  final String specialization;
  final double rating;
  final int cases;
  final bool verified;
  final String city;
  final String about;

  const LawyerData({
    required this.id,
    required this.name,
    required this.specialization,
    required this.rating,
    required this.cases,
    required this.verified,
    required this.city,
    required this.about,
  });

  String get initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts[0][0].toUpperCase();
  }
}

/// Datos mock globales de abogados (compartidos entre pantallas).
final mockLawyers = [
  const LawyerData(
    id: 'l1',
    name: 'Dra. María González',
    specialization: 'Derecho de Familia',
    rating: 4.8,
    cases: 47,
    verified: true,
    city: 'Tegucigalpa',
    about:
        'Especialista en divorcios, custodia y pensión alimenticia con 12 años de experiencia.',
  ),
  const LawyerData(
    id: 'l2',
    name: 'Lic. Carlos Méndez',
    specialization: 'Derecho Laboral',
    rating: 4.6,
    cases: 31,
    verified: true,
    city: 'San Pedro Sula',
    about: 'Experto en despidos injustificados y demandas laborales.',
  ),
  const LawyerData(
    id: 'l3',
    name: 'Abg. Ana Flores',
    specialization: 'Derecho Penal',
    rating: 4.9,
    cases: 58,
    verified: true,
    city: 'Tegucigalpa',
    about:
        'Defensora penal con experiencia en casos criminales y amparo.',
  ),
  const LawyerData(
    id: 'l4',
    name: 'Dr. Roberto Paz',
    specialization: 'Derecho Mercantil',
    rating: 4.5,
    cases: 22,
    verified: true,
    city: 'Comayagüela',
    about:
        'Especialista en contratos, sociedades y derecho comercial.',
  ),
];

/// Tarjeta estándar de abogado.
///
/// Si [compact] es true muestra una versión más pequeña
/// para el scroll horizontal en la pantalla de inicio.
class LawyerCard extends StatelessWidget {
  final LawyerData lawyer;
  final VoidCallback onVerPerfil;
  final bool compact;

  const LawyerCard({
    super.key,
    required this.lawyer,
    required this.onVerPerfil,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return compact ? _CompactCard(lawyer: lawyer, onVerPerfil: onVerPerfil) : _FullCard(lawyer: lawyer, onVerPerfil: onVerPerfil);
  }
}

class _FullCard extends StatelessWidget {
  final LawyerData lawyer;
  final VoidCallback onVerPerfil;

  const _FullCard({required this.lawyer, required this.onVerPerfil});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.cardGap),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        border: Border.all(color: AppColors.borderColor),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.cardPadding),
        child: Row(
          children: [
            _Avatar(initials: lawyer.initials, size: 52),
            const SizedBox(width: AppSizes.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          lawyer.name,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppColors.greyDark,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (lawyer.verified)
                        const Icon(
                          Icons.verified_rounded,
                          size: 16,
                          color: AppColors.successGreen,
                        ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    lawyer.specialization,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.primaryBlue,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 13,
                        color: AppColors.greyMedium,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        lawyer.city,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.greyMedium,
                        ),
                      ),
                      const SizedBox(width: AppSizes.sm),
                      _StarRating(rating: lawyer.rating),
                      const SizedBox(width: 4),
                      Text(
                        '${lawyer.rating}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.greyMedium,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${lawyer.cases} casos atendidos',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.greyMedium,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSizes.sm),
            TextButton(
              onPressed: onVerPerfil,
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primaryBlue,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.sm,
                  vertical: AppSizes.xs,
                ),
              ),
              child: const Text(
                'Ver perfil',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CompactCard extends StatelessWidget {
  final LawyerData lawyer;
  final VoidCallback onVerPerfil;

  const _CompactCard({required this.lawyer, required this.onVerPerfil});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: AppSizes.cardGap),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        border: Border.all(color: AppColors.borderColor),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                _Avatar(initials: lawyer.initials, size: 40),
                const Spacer(),
                if (lawyer.verified)
                  const Icon(
                    Icons.verified_rounded,
                    size: 14,
                    color: AppColors.successGreen,
                  ),
              ],
            ),
            const SizedBox(height: AppSizes.sm),
            Text(
              lawyer.name,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppColors.greyDark,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              lawyer.specialization,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.primaryBlue,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            _StarRating(rating: lawyer.rating, size: 11),
            const SizedBox(height: AppSizes.sm),
            GestureDetector(
              onTap: onVerPerfil,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: AppSizes.xs,
                ),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.primaryBlue),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'Ver perfil',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.primaryBlue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final String initials;
  final double size;

  const _Avatar({required this.initials, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.primaryBlue.withOpacity(0.12),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: TextStyle(
          fontSize: size * 0.35,
          fontWeight: FontWeight.bold,
          color: AppColors.primaryBlue,
        ),
      ),
    );
  }
}

class _StarRating extends StatelessWidget {
  final double rating;
  final double size;

  const _StarRating({required this.rating, this.size = 12});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        if (i < rating.floor()) {
          return Icon(Icons.star_rounded, size: size, color: AppColors.secondaryOrange);
        } else if (i < rating) {
          return Icon(Icons.star_half_rounded, size: size, color: AppColors.secondaryOrange);
        } else {
          return Icon(Icons.star_outline_rounded, size: size, color: AppColors.greyLight);
        }
      }),
    );
  }
}
