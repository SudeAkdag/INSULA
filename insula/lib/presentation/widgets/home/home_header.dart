// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      // Left padding increased to 80 to avoid overlap with floating menu button
      padding: const EdgeInsets.only(
          left: 80.0, right: 24.0, top: 12.0, bottom: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              // Avatar
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primary, width: 2),
                  image: const DecorationImage(
                    image: NetworkImage(
                        "https://lh3.googleusercontent.com/aida-public/AB6AXuDAESvp-Cz8XYs7PkZlDp53ygqp6KjZ4kAfTrFmvFR6nTTYmXYPrrlkqmlFGzZmqlrx6-uWsWQu6EUvkE5AxwEWgk5JGPzay8EWsByY98nt3ATu1W8GrAo7OLvlm67dvwezTHszbTFk6VdqTDW4puIEODx6QguO0iCcv_0zoqPPAhwjN9SzGMYPSXyQ6QGBv4DEV4UM_3LflcbPd3T7UrViNP2vYd0k2dGsMEM9KC6FlUL19qFb81VgElf7vorL0kxrjOyxJKx8fKY"),
                    fit: BoxFit.cover,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Welcome Text
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Hoş geldin,",
                    style: AppTextStyles.label
                        .copyWith(fontSize: 10, color: Colors.black),
                  ),
                  Text(
                    "İsim Soyisim",
                    style: AppTextStyles.h1.copyWith(fontSize: 16, height: 1.0),
                  ),
                ],
              ),
            ],
          ),
          // Notification Button
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              icon: const Icon(Icons.notifications_none,
                  color: AppColors.secondary),
              onPressed: () {},
              iconSize: 24,
              padding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    );
  }
}
