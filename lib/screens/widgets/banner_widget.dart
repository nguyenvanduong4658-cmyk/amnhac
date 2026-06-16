import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

class BannerCarousel extends StatefulWidget {
  final List<String> banners;

  const BannerCarousel({super.key, required this.banners});

  @override
  State<BannerCarousel> createState() => _BannerCarouselState();
}

class _BannerCarouselState extends State<BannerCarousel> {
  final CarouselSliderController controller = CarouselSliderController();

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        CarouselSlider(
          carouselController: controller,
          items: widget.banners.map((url) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Image.network(
                url,
                fit: BoxFit.cover,
                width: double.infinity,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: const Color(0xFF242424),
                  width: double.infinity,
                  height: 220,
                  child: const Icon(Icons.broken_image, color: Colors.white30, size: 40),
                ),
              ),
            );
          }).toList(),
          options: CarouselOptions(
            height: 220,
            autoPlay: true,
            enlargeCenterPage: true,
            viewportFraction: 0.8,
          ),
        ),
        Positioned(
          left: 10,
          child: IconButton(
            onPressed: () {
              controller.previousPage();
            },
            icon: const CircleAvatar(
              child: Icon(Icons.arrow_back_ios_new_rounded),
            ),
          ),
        ),
        Positioned(
          right: 10,
          child: IconButton(
            onPressed: () {
              controller.nextPage();
            },
            icon: const CircleAvatar(
              child: Icon(Icons.arrow_forward_ios_rounded),
            ),
          ),
        ),
      ],
    );
  }
}