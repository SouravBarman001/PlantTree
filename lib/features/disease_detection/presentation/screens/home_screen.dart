import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/utils/locale_provider.dart';
import '../../../../core/utils/theme.dart';
import '../../../../core/utils/weather_service.dart';
import '../providers/disease_provider.dart';

class PlantExploreItem {
  final String name;
  final String family;
  final String imagePath;
  final Color color;
  final String soil;
  final String water;
  final String sun;
  final String temp;
  final List<String> diseases;

  const PlantExploreItem({
    required this.name,
    required this.family,
    required this.imagePath,
    required this.color,
    required this.soil,
    required this.water,
    required this.sun,
    required this.temp,
    required this.diseases,
  });
}

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentIndex = 0;
  String _searchQuery = "";

  static const Color _ink = Color(0xFF20242A);
  static const Color _mintPanel = Color(0xFFE8F5E9);
  static const Color _weatherCard = Color(0xFFFFF8E1);
  static const Color _weatherBorder = Color(0xFFFFB300);

  Map<String, Map<String, dynamic>> _diseaseDetails = {};
  WeatherData? _weatherData;
  bool _isLoadingWeather = false;
  bool _isInternetAvailable = true;
  final WeatherService _weatherService = WeatherService();

  final List<PlantExploreItem> _explorePlants = const [
    PlantExploreItem(
      name: "Apple",
      family: "Rosaceae family",
      imagePath: "assets/icon/apple.png",
      color: Color(0xFFD97868),
      soil: "Well-drained loam, pH 6.0-6.8",
      water: "Moderate, 1 inch/week",
      sun: "Full sun, 6-8 hours daily",
      temp: "15°C - 25°C",
      diseases: ["apple apple scab", "apple black rot", "apple cedar apple rust", "apple healthy"],
    ),
    PlantExploreItem(
      name: "Pepper",
      family: "Solanaceae family",
      imagePath: "assets/icon/bell-pepper.png",
      color: Color(0xFF7ED321),
      soil: "Rich loamy soil, pH 6.0-6.8",
      water: "Moderate, keep evenly moist",
      sun: "Full sun, 6-8 hours daily",
      temp: "21°C - 29°C",
      diseases: ["pepper bell bacterial spot", "pepper bell healthy"],
    ),
    PlantExploreItem(
      name: "Corn",
      family: "Poaceae family",
      imagePath: "assets/icon/corn.png",
      color: Color(0xFFF5A623),
      soil: "Rich, well-draining loamy, pH 6.0-6.8",
      water: "High, 1.5-2 inches/week",
      sun: "Full sun, 8+ hours daily",
      temp: "20°C - 30°C",
      diseases: ["corn maize cercospora leaf spot gray leaf spot", "corn maize common rust", "corn maize northern leaf blight", "corn maize healthy"],
    ),
    PlantExploreItem(
      name: "Grape",
      family: "Vitaceae family",
      imagePath: "assets/icon/grape.png",
      color: Color(0xFF9013FE),
      soil: "Deep, gravelly or sandy loam, pH 5.5-6.5",
      water: "Low to moderate, water deeply",
      sun: "Full sun, 8 hours daily",
      temp: "15°C - 30°C",
      diseases: ["grape black rot", "grape esca black measles", "grape leaf blight isariopsis leaf spot", "grape healthy"],
    ),
    PlantExploreItem(
      name: "Peach",
      family: "Rosaceae family",
      imagePath: "assets/icon/peach.png",
      color: Color(0xFFFFB076),
      soil: "Sandy loam, well-drained, pH 6.0-6.5",
      water: "Moderate, 1 inch/week",
      sun: "Full sun, 6-8 hours daily",
      temp: "18°C - 26°C",
      diseases: ["peach bacterial spot", "peach healthy"],
    ),
    PlantExploreItem(
      name: "Strawberry",
      family: "Rosaceae family",
      imagePath: "assets/icon/strawberry.png",
      color: Color(0xFFD0021B),
      soil: "Deep sandy loam, rich in organic, pH 5.5-6.5",
      water: "Moderate, 1-2 inches/week",
      sun: "Full sun, 8 hours daily",
      temp: "15°C - 25°C",
      diseases: ["strawberry leaf scorch", "strawberry healthy"],
    ),
    PlantExploreItem(
      name: "Tomato",
      family: "Solanaceae family",
      imagePath: "assets/icon/tomato.png",
      color: Color(0xFFE31B23),
      soil: "Fertile, well-draining loamy, pH 6.2-6.8",
      water: "Regular deep watering, 1-2 inches/week",
      sun: "Full sun, 6-8 hours daily",
      temp: "21°C - 29°C",
      diseases: [
        "tomato bacterial spot",
        "tomato early blight",
        "tomato late blight",
        "tomato leaf mold",
        "tomato septoria leaf spot",
        "tomato spider mites two spotted spider mite",
        "tomato target spot",
        "tomato yellow leaf curl virus",
        "tomato mosaic virus",
        "tomato healthy"
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadDiseaseDetails();
    _fetchWeatherSilently();
  }

  Future<void> _loadDiseaseDetails() async {
    try {
      final String data = await DefaultAssetBundle.of(context).loadString('assets/data.json');
      final Map<String, dynamic> decoded = jsonDecode(data);
      final List<dynamic> diseaseList = decoded['plant_disease'] ?? [];
      final Map<String, Map<String, dynamic>> tempDb = {};
      for (var item in diseaseList) {
        if (item is Map<String, dynamic> && item.containsKey('name')) {
          tempDb[item['name'].toString().trim().toLowerCase()] = item;
        }
      }
      setState(() {
        _diseaseDetails = tempDb;
      });
    } catch (e) {
      debugPrint("Error loading disease details: $e");
    }
  }

  Future<void> _fetchWeatherSilently() async {
    final permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.always || permission == LocationPermission.whileInUse) {
      _fetchWeather();
    }
  }

  Future<void> _fetchWeather() async {
    setState(() {
      _isLoadingWeather = true;
      _isInternetAvailable = true;
    });

    try {
      final lookup = await InternetAddress.lookup('google.com').timeout(const Duration(seconds: 4));
      if (lookup.isEmpty || lookup[0].rawAddress.isEmpty) {
        if (mounted) {
          setState(() {
            _isInternetAvailable = false;
            _isLoadingWeather = false;
          });
        }
        return;
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isInternetAvailable = false;
          _isLoadingWeather = false;
        });
      }
      return;
    }

    final data = await _weatherService.getLocalWeather();
    if (mounted) {
      setState(() {
        _weatherData = data;
        _isLoadingWeather = false;
      });
    }
  }

  Future<bool> _showExitConfirmationDialog(BuildContext context) async {
    final theme = Theme.of(context);
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: AlertDialog(
            backgroundColor: theme.scaffoldBackgroundColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Text(
              ref.tr('exit_app'),
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: theme.colorScheme.onSurface,
              ),
            ),
            content: Text(
              ref.tr('exit_confirmation'),
              style: GoogleFonts.inter(
                fontSize: 14,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(
                  ref.tr('cancel'),
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  ref.tr('exit'),
                  style: GoogleFonts.inter(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        );
      },
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldExit = await _showExitConfirmationDialog(context);
        if (shouldExit && mounted) {
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Stack(
          children: [
            Positioned.fill(
              child: IndexedStack(
                index: _currentIndex,
                children: [
                  _buildHomeTab(context),
                  _buildExploreTab(context),
                  _buildSettingsTab(context),
                ],
              ),
            ),
            Positioned(
              left: 20,
              right: 20,
              bottom: 20,
              child: _buildFloatingBottomNavBar(context),
            ),
          ],
        ),
      ),
    );
  }

  // --- FLOATING BOTTOM NAVIGATION BAR ---
  Widget _buildFloatingBottomNavBar(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          height: 72,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.darkSurface.withValues(alpha: 0.85)
                : Colors.white.withValues(alpha: 0.88),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.grey.withValues(alpha: 0.2),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildFloatingNavItem(
                index: 0,
                icon: Icons.yard_outlined,
                activeIcon: Icons.yard_rounded,
                label: ref.tr('home'),
              ),
              _buildFloatingNavItem(
                index: 1,
                icon: Icons.explore_outlined,
                activeIcon: Icons.explore_rounded,
                label: ref.tr('explore'),
              ),
              _buildFloatingNavItem(
                index: 2,
                icon: Icons.settings_outlined,
                activeIcon: Icons.settings_rounded,
                label: ref.tr('settings'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingNavItem({
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
  }) {
    final theme = Theme.of(context);
    final isSelected = _currentIndex == index;
    final primaryColor = theme.colorScheme.primary;
    final color = isSelected ? primaryColor : theme.colorScheme.onSurface.withValues(alpha: 0.6);

    return InkWell(
      onTap: () => setState(() => _currentIndex = index),
      borderRadius: BorderRadius.circular(24),
      child: SizedBox(
        width: 80,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 44,
              height: 28,
              decoration: BoxDecoration(
                color: isSelected ? primaryColor.withValues(alpha: 0.15) : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(isSelected ? activeIcon : icon, size: 20, color: color),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- HOME TAB (COMPACT & RESPONSIVE) ---
  Widget _buildHomeTab(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _buildHeader(context)),
              SliverToBoxAdapter(child: _buildCropSelector(context)),
              SliverToBoxAdapter(child: _buildWeatherAndDiagnosis(context)),
              SliverToBoxAdapter(child: _buildToolsSection(context)),
              const SliverToBoxAdapter(child: SizedBox(height: 110)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ref.tr('app_name'),
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.primary,
                  ),
                ),
                Text(
                  ref.tr('subtitle'),
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: _fetchWeather,
            icon: const Icon(Icons.my_location_rounded, size: 22),
            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ],
      ),
    );
  }

  Widget _buildCropSelector(BuildContext context) {
    return SizedBox(
      height: 104,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
        itemBuilder: (context, index) {
          final plant = _explorePlants[index];
          return _buildCropItem(plant);
        },
        separatorBuilder: (context, index) => const SizedBox(width: 14),
        itemCount: _explorePlants.length,
      ),
    );
  }

  Widget _buildCropItem(PlantExploreItem plant) {
    return InkWell(
      onTap: () => _showPlantDetailSheet(context, plant),
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        width: 66,
        child: Column(
          children: [
            Container(
              width: 58,
              height: 58,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                shape: BoxShape.circle,
                border: Border.all(color: plant.color.withValues(alpha: 0.5), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Image.asset(
                plant.imagePath,
                width: 36,
                height: 36,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              ref.tr(plant.name),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: _ink,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherAndDiagnosis(BuildContext context) {
    final theme = Theme.of(context);
    final showLocationPrompt = _weatherData == null && !_isLoadingWeather && _isInternetAvailable;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      color: _mintPanel,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 74,
            child: !_isInternetAvailable
                ? Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: theme.brightness == Brightness.dark
                          ? Colors.red[900]?.withValues(alpha: 0.2)
                          : Colors.red[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: theme.brightness == Brightness.dark
                            ? Colors.red[800]!.withValues(alpha: 0.4)
                            : Colors.red[200]!,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.wifi_off_rounded,
                          color: theme.brightness == Brightness.dark
                              ? Colors.red[200]
                              : Colors.red[800],
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          ref.tr('turn_on_internet'),
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: theme.brightness == Brightness.dark
                                ? Colors.red[200]
                                : Colors.red[800],
                          ),
                        ),
                      ],
                    ),
                  )
                : _isLoadingWeather
                    ? Shimmer.fromColors(
                        baseColor: theme.brightness == Brightness.dark ? Colors.grey[800]! : Colors.grey[300]!,
                        highlightColor: theme.brightness == Brightness.dark ? Colors.grey[700]! : Colors.grey[100]!,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          physics: const NeverScrollableScrollPhysics(),
                          child: Row(
                            children: [
                              Container(
                                width: 134,
                                height: 74,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Container(
                                width: 220,
                                height: 74,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          _buildWeatherCard(
                            width: 134,
                            icon: _getWeatherIcon(_weatherData?.condition),
                            title: _weatherData?.cityName ?? 'Dhaka',
                            value: _weatherData != null
                                ? '${_weatherData!.temperature.toStringAsFixed(1)}°C'
                                : '24°C',
                            trailing: _weatherData != null ? null : Icons.cloud_rounded,
                          ),
                          const SizedBox(width: 10),
                          _buildWeatherCard(
                            width: 220,
                            icon: Icons.wind_power_outlined,
                            title: ref.tr('spraying_conditions'),
                            value: ref.tr(_weatherData?.sprayingCondition ?? 'Moderate'),
                            rightText: _weatherData != null
                                ? '${ref.tr('wind')} ${_weatherData!.windSpeed.toStringAsFixed(1)} ${ref.tr('km_h')}'
                                : ref.tr('until_12_am'),
                          ),
                        ],
                      ),
          ),
          if (showLocationPrompt) ...[
            const SizedBox(height: 18),
            _buildLocationPrompt(context),
          ],
          const SizedBox(height: 22),
          _buildDiagnosisCard(context),
        ],
      ),
    );
  }

  IconData _getWeatherIcon(String? condition) {
    if (condition == null) return Icons.wb_sunny_rounded;
    final lower = condition.toLowerCase();
    if (lower.contains('rain') || lower.contains('drizzle') || lower.contains('thunderstorm')) {
      return Icons.umbrella_rounded;
    } else if (lower.contains('cloud') || lower.contains('mist') || lower.contains('fog')) {
      return Icons.cloud_rounded;
    }
    return Icons.wb_sunny_rounded;
  }

  Widget _buildWeatherCard({
    required double width,
    required IconData icon,
    required String title,
    required String value,
    IconData? trailing,
    String? rightText,
  }) {
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: _weatherCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _weatherBorder.withValues(alpha: 0.6), width: 1.2),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Icon(icon, size: 13, color: const Color(0xFF6F4B08)),
                    const SizedBox(width: 5),
                    Flexible(
                      child: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: const Color(0xFF6F4B08),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF4E3200),
                  ),
                ),
              ],
            ),
          ),
          if (trailing != null) Icon(trailing, size: 28, color: Colors.amber),
          if (rightText != null)
            Text(
              rightText,
              style: GoogleFonts.inter(
                fontSize: 11,
                color: const Color(0xFF6F4B08),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLocationPrompt(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Icon(Icons.location_on_outlined, size: 22, color: _ink),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            ref.tr('location_permission_msg'),
            style: GoogleFonts.inter(fontSize: 12, height: 1.2, color: _ink),
          ),
        ),
        const SizedBox(width: 10),
        TextButton(
          onPressed: _fetchWeather,
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            ref.tr('allow'),
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDiagnosisCard(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 18),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildDiagnosisStep(
                  icon: Icons.center_focus_strong_rounded,
                  label: ref.tr('take_picture_step'),
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                size: 22,
                color: Color(0xFF9AAEBB),
              ),
              Expanded(
                child: _buildDiagnosisStep(
                  icon: Icons.fact_check_outlined,
                  label: ref.tr('see_diagnosis_step'),
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                size: 22,
                color: Color(0xFF9AAEBB),
              ),
              Expanded(
                child: _buildDiagnosisStep(
                  icon: Icons.medication_liquid_rounded,
                  label: ref.tr('get_medicine_step'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/scan'),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              child: Text(
                ref.tr('take_a_picture'),
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiagnosisStep({required IconData icon, required String label}) {
    return Column(
      children: [
        Icon(icon, size: 36, color: const Color(0xFF073D4C)),
        const SizedBox(height: 8),
        Text(
          label,
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(fontSize: 12, height: 1.2, color: _ink),
        ),
      ],
    );
  }

  Widget _buildToolsSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            ref.tr('tools'),
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: _ink,
            ),
          ),
          const SizedBox(height: 12),
          GridView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1.45,
            ),
            children: [
              _buildToolCard(
                label: ref.tr('spray_guide'),
                icon: Icons.cleaning_services_rounded,
                isNew: true,
                onTap: () => _showSprayGuideDialog(context),
              ),
              _buildToolCard(
                label: ref.tr('fertilizer'),
                icon: Icons.calculate_outlined,
                isNew: true,
                onTap: () => _showFertilizerCalculatorDialog(context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildToolCard({
    required String label,
    required IconData icon,
    required bool isNew,
    required VoidCallback onTap,
  }) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: double.infinity,
            height: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: const BoxDecoration(
                    color: Color(0xFFEBF4FF),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    size: 20,
                    color: const Color(0xFF0A2A5C),
                  ),
                ),
                const Spacer(),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _ink,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (isNew)
          Positioned(
            top: -4,
            right: -4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFF3E8FF),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                ref.tr('new_tag'),
                style: GoogleFonts.inter(
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF6B21A8),
                ),
              ),
            ),
          ),
      ],
    );
  }

  // --- INTERACTIVE SPRAY GUIDE DIALOG ---
  void _showSprayGuideDialog(BuildContext context) {
    final theme = Theme.of(context);
    final cropsList = _explorePlants.map((e) => e.name).toList();
    final stages = [
      ref.tr('seedling_early'),
      ref.tr('flowering_bloom'),
      ref.tr('fruiting_harvest')
    ];

    int selectedCropIdx = 0;
    int selectedStageIdx = 0;
    bool isSimulating = false;
    String? simulationResult;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            final cropName = cropsList[selectedCropIdx];
            final recKey = '${cropName.toLowerCase()}_rec_$selectedStageIdx';
            final currentRec = ref.tr(recKey);

            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Text(
                ref.tr('interactive_spray_guide'),
                style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ref.tr('crop_selection'),
                      style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<int>(
                          value: selectedCropIdx,
                          isExpanded: true,
                          items: List.generate(cropsList.length, (index) {
                            return DropdownMenuItem(
                              value: index,
                              child: Text(ref.tr(cropsList[index]), style: GoogleFonts.inter(fontSize: 13)),
                            );
                          }),
                          onChanged: (val) {
                            if (val != null) setState(() => selectedCropIdx = val);
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      ref.tr('growth_stage'),
                      style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<int>(
                          value: selectedStageIdx,
                          isExpanded: true,
                          items: List.generate(stages.length, (index) {
                            return DropdownMenuItem(
                              value: index,
                              child: Text(stages[index], style: GoogleFonts.inter(fontSize: 13)),
                            );
                          }),
                          onChanged: (val) {
                            if (val != null) setState(() => selectedStageIdx = val);
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.2)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            ref.tr('recommendation_header'),
                            style: GoogleFonts.inter(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            currentRec,
                            style: GoogleFonts.inter(fontSize: 12, height: 1.4, color: _ink),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (isSimulating)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(12.0),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    else if (simulationResult != null)
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: (simulationResult!.contains('✅') || simulationResult!.contains('verified') || simulationResult!.contains('যাচাই')) ? Colors.green[50] : Colors.red[50],
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: (simulationResult!.contains('✅') || simulationResult!.contains('verified') || simulationResult!.contains('যাচাই')) ? Colors.green[200]! : Colors.red[200]!,
                          ),
                        ),
                        child: Text(
                          simulationResult!,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: (simulationResult!.contains('✅') || simulationResult!.contains('verified') || simulationResult!.contains('যাচাই')) ? Colors.green[800] : Colors.red[800],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(ref.tr('close'), style: GoogleFonts.inter(fontSize: 13)),
                ),
                ElevatedButton(
                  onPressed: isSimulating
                      ? null
                      : () {
                          setState(() {
                            isSimulating = true;
                          });
                          Future.delayed(const Duration(milliseconds: 1200), () {
                            if (mounted) {
                              setState(() {
                                isSimulating = false;
                                if (_weatherData != null) {
                                  final wind = _weatherData!.windSpeed;
                                  final cond = _weatherData!.condition.toLowerCase();

                                  if (cond.contains('rain') || cond.contains('drizzle')) {
                                    simulationResult = ref.tr('rain_alert');
                                  } else if (wind > 15.0) {
                                    simulationResult = ref.tr('wind_alert').replaceAll('{wind}', wind.toStringAsFixed(1));
                                  } else {
                                    simulationResult = ref.tr('safe_alert').replaceAll('{wind}', wind.toStringAsFixed(1));
                                  }
                                } else {
                                  simulationResult = ref.tr('demo_alert');
                                }
                              });
                            }
                          });
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Text(ref.tr('verify_safety'), style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // --- INTERACTIVE FERTILIZER CALCULATOR ---
  void _showFertilizerCalculatorDialog(BuildContext context) {
    final theme = Theme.of(context);
    final cropsList = _explorePlants.map((e) => e.name).toList();
    final fertilizers = [
      ref.tr('NPK 10-10-10 (Balanced Feed)'),
      ref.tr('Urea (46-0-0 Nitrogen Booster)'),
      ref.tr('Organic Compost (Slow Release)')
    ];

    int selectedCropIdx = 0;
    int selectedFertilizerIdx = 0;
    double areaSize = 100.0;
    bool showCalculatedResult = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Text(
                ref.tr('fertilizer_calculator'),
                style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ref.tr('target_crop'),
                      style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<int>(
                          value: selectedCropIdx,
                          isExpanded: true,
                          items: List.generate(cropsList.length, (index) {
                            return DropdownMenuItem(
                              value: index,
                              child: Text(ref.tr(cropsList[index]), style: GoogleFonts.inter(fontSize: 13)),
                            );
                          }),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() {
                                selectedCropIdx = val;
                                showCalculatedResult = false;
                              });
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      ref.tr('fertilizer_feed_type'),
                      style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<int>(
                          value: selectedFertilizerIdx,
                          isExpanded: true,
                          items: List.generate(fertilizers.length, (index) {
                            return DropdownMenuItem(
                              value: index,
                              child: Text(fertilizers[index], style: GoogleFonts.inter(fontSize: 13)),
                            );
                          }),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() {
                                selectedFertilizerIdx = val;
                                showCalculatedResult = false;
                              });
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          ref.tr('garden_area_size'),
                          style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey),
                        ),
                        Text(
                          '${areaSize.toInt()} ${ref.tr('locale_provider') == 'bn' ? 'বর্গ ফুট' : 'sq ft'}',
                          style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: theme.colorScheme.primary),
                        ),
                      ],
                    ),
                    Slider(
                      value: areaSize,
                      min: 10.0,
                      max: 800.0,
                      divisions: 79,
                      activeColor: theme.colorScheme.primary,
                      onChanged: (val) {
                        setState(() {
                          areaSize = val;
                          showCalculatedResult = false;
                        });
                      },
                    ),
                    if (showCalculatedResult) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.green[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.green[200]!),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              ref.tr('calculated_dosage'),
                              style: GoogleFonts.inter(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: Colors.green[800],
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              _getCalculatedAmount(selectedFertilizerIdx, areaSize, cropsList[selectedCropIdx]),
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.green[900],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              ref.tr('application_guide'),
                              style: GoogleFonts.inter(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[700],
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _getFertilizerInstructions(selectedFertilizerIdx),
                              style: GoogleFonts.inter(fontSize: 11, height: 1.4, color: Colors.grey[800]),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(ref.tr('close'), style: GoogleFonts.inter(fontSize: 13)),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      showCalculatedResult = true;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Text(ref.tr('calculate'), style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  String _getCalculatedAmount(int type, double area, String cropName) {
    final transCrop = ref.tr(cropName);
    final isBn = ref.read(localeProvider) == 'bn';
    if (type == 0) {
      // NPK: 0.005 kg per sq ft
      final amount = area * 0.005;
      if (isBn) {
        return '$transCrop-এর জন্য NPK 10-10-10: ${amount.toStringAsFixed(2)} কেজি (বা ${(amount * 2.204).toStringAsFixed(1)} পাউন্ড)';
      }
      return '${amount.toStringAsFixed(2)} kg (or ${(amount * 2.204).toStringAsFixed(1)} lbs) of NPK 10-10-10 for $transCrop';
    } else if (type == 1) {
      // Urea: 0.002 kg per sq ft
      final amount = area * 0.002;
      if (isBn) {
        return '$transCrop-এর জন্য ইউরিয়া: ${amount.toStringAsFixed(2)} কেজি (বা ${(amount * 2.204).toStringAsFixed(1)} পাউন্ড)';
      }
      return '${amount.toStringAsFixed(2)} kg (or ${(amount * 2.204).toStringAsFixed(1)} lbs) of Urea for $transCrop';
    } else {
      // Compost: 0.05 kg per sq ft
      final amount = area * 0.05;
      if (isBn) {
        return '$transCrop-এর জন্য কম্পোস্ট সার: ${amount.toStringAsFixed(1)} কেজি (বা ${(amount * 2.204).toStringAsFixed(1)} পাউন্ড)';
      }
      return '${amount.toStringAsFixed(1)} kg (or ${(amount * 2.204).toStringAsFixed(1)} lbs) of Compost manure for $transCrop';
    }
  }

  String _getFertilizerInstructions(int type) {
    if (type == 0) {
      return ref.tr('npk_instruction');
    } else if (type == 1) {
      return ref.tr('urea_instruction');
    } else {
      return ref.tr('compost_instruction');
    }
  }

  // --- EXPLORE TAB ---
  Widget _buildExploreTab(BuildContext context) {
    final theme = Theme.of(context);
    
    final filteredPlants = _explorePlants.where((plant) {
      final transName = ref.read(translationProvider)[plant.name.toLowerCase()] ?? plant.name;
      final transFamily = ref.read(translationProvider)[plant.family.toLowerCase()] ?? plant.family;
      return transName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          transFamily.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return SafeArea(
      bottom: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ref.tr('explore_crops'),
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.primary,
                  ),
                ),
                Text(
                  ref.tr('explore_subtitle'),
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Container(
              height: 42,
              decoration: BoxDecoration(
                color: theme.brightness == Brightness.dark
                    ? AppColors.darkSurface
                    : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
              ),
              child: TextField(
                onChanged: (val) => setState(() => _searchQuery = val),
                style: GoogleFonts.inter(fontSize: 13),
                decoration: InputDecoration(
                  hintText: ref.tr('search_plants'),
                  hintStyle: GoogleFonts.inter(fontSize: 13, color: Colors.grey),
                  prefixIcon: const Icon(Icons.search_rounded, size: 18, color: Colors.grey),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 110),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 1.15,
              ),
              itemCount: filteredPlants.length,
              itemBuilder: (context, index) {
                final plant = filteredPlants[index];
                return _buildPlantExploreCard(context, plant);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlantExploreCard(BuildContext context, PlantExploreItem plant) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return InkWell(
      onTap: () => _showPlantDetailSheet(context, plant),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.05)
                : Colors.grey.withValues(alpha: 0.15),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: plant.color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Image.asset(
                plant.imagePath,
                width: 24,
                height: 24,
                fit: BoxFit.contain,
              ),
            ),
            const Spacer(),
            Text(
              ref.tr(plant.name),
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              ref.tr(plant.family),
              style: GoogleFonts.inter(
                fontSize: 11,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPlantDetailSheet(BuildContext context, PlantExploreItem plant) {
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.8,
          maxChildSize: 0.95,
          minChildSize: 0.5,
          builder: (context, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
              ),
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: ListView(
                controller: scrollController,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey[400],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: plant.color.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Image.asset(
                          plant.imagePath,
                          width: 36,
                          height: 36,
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              ref.tr(plant.name),
                              style: GoogleFonts.poppins(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                            Text(
                              ref.tr(plant.family),
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    ref.tr('planting_guide'),
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 10),
                  GridThemeGuide(
                    soil: ref.tr(plant.soil),
                    water: ref.tr(plant.water),
                    sun: ref.tr(plant.sun),
                    temp: ref.tr(plant.temp),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    ref.tr('common_diseases'),
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (plant.diseases.isEmpty)
                    Text(
                      ref.tr('no_common_diseases'),
                      style: GoogleFonts.inter(fontSize: 13, color: Colors.grey),
                    )
                  else
                    ...plant.diseases.map((dName) {
                      final details = _diseaseDetails[dName.trim().toLowerCase()];
                      final String displayName = dName
                          .split(' ')
                          .map((word) => word.isNotEmpty ? word[0].toUpperCase() + word.substring(1) : '')
                          .join(' ');
                      
                      final transDisease = ref.tr(dName);
                      final displayTitle = transDisease == dName ? displayName : transDisease;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        elevation: 1,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: ExpansionTile(
                          shape: const Border(),
                          title: Text(
                            displayTitle,
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: dName.toLowerCase().contains('healthy')
                                  ? Colors.green[700]
                                  : theme.colorScheme.onSurface,
                            ),
                          ),
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    ref.tr('symptoms'),
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.amber[800],
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    details?['symptoms'] ?? 'Loading symptoms details...',
                                    style: GoogleFonts.inter(fontSize: 12),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    ref.tr('management_guide'),
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: theme.colorScheme.primary,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    details?['management'] ?? 'Loading management steps...',
                                    style: GoogleFonts.inter(fontSize: 12),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      );
                    }),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // --- SETTINGS TAB (ONLY MODEL STATUS INFO) ---
  Widget _buildSettingsTab(BuildContext context) {
    final theme = Theme.of(context);
    final bool isModelLoaded = ref.watch(diseaseRepositoryProvider).isModelLoaded;

    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 110),
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                ref.tr('settings'),
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.primary,
                ),
              ),
              Text(
                ref.tr('diagnostics_sub'),
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildSettingsHeader(ref.tr('app_language')),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              leading: Icon(Icons.language_rounded, color: theme.colorScheme.primary),
              title: Text(
                ref.tr('app_language'),
                style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                ref.watch(localeProvider) == 'en' ? 'English' : 'বাংলা',
                style: GoogleFonts.inter(fontSize: 12, color: Colors.grey),
              ),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => _showLanguageSelectorBottomSheet(context),
            ),
          ),
          const SizedBox(height: 20),
          _buildSettingsHeader(ref.tr('diagnostics_header')),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        ref.tr('model_status'),
                        style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: isModelLoaded ? Colors.green[100] : Colors.amber[100],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          isModelLoaded ? ref.tr('model_loaded') : ref.tr('model_standby'),
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: isModelLoaded ? Colors.green[800] : Colors.amber[800],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 20),
                  _buildDiagRow(ref.tr('asset_model'), 'model.tflite'),
                  _buildDiagRow(ref.tr('input_shape'), '[1, 200, 200, 3] Float32'),
                  _buildDiagRow(ref.tr('output_classes'), ref.watch(localeProvider) == 'bn' ? '৩৯টি উদ্ভিদ ও রোগের ধরণ' : '39 plant & disease types'),
                  _buildDiagRow(ref.tr('mean_std'), '0.0 / 255.0'),
                  _buildDiagRow(ref.tr('threshold'), '40%'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showLanguageSelectorBottomSheet(BuildContext context) {
    final theme = Theme.of(context);
    final currentLocale = ref.read(localeProvider);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 8, bottom: 16),
                child: Text(
                  ref.tr('select_language'),
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ListTile(
                title: Text(ref.tr('english'), style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500)),
                trailing: currentLocale == 'en' ? Icon(Icons.check_circle_rounded, color: theme.colorScheme.primary) : null,
                onTap: () {
                  ref.read(localeProvider.notifier).setLocale('en');
                  Navigator.pop(context);
                },
              ),
              const Divider(height: 1),
              ListTile(
                title: Text(ref.tr('bangla'), style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500)),
                trailing: currentLocale == 'bn' ? Icon(Icons.check_circle_rounded, color: theme.colorScheme.primary) : null,
                onTap: () {
                  ref.read(localeProvider.notifier).setLocale('bn');
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSettingsHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: GoogleFonts.inter(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
          color: Colors.grey[600],
        ),
      ),
    );
  }

  Widget _buildDiagRow(String label, String val) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.inter(fontSize: 12, color: Colors.grey[600])),
          Text(val, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class GridThemeGuide extends StatelessWidget {
  final String soil;
  final String water;
  final String sun;
  final String temp;

  const GridThemeGuide({
    super.key,
    required this.soil,
    required this.water,
    required this.sun,
    required this.temp,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 8,
      mainAxisSpacing: 8,
      childAspectRatio: 2.2,
      children: [
        _buildGuideCell(Icons.layers_outlined, 'SOIL', soil),
        _buildGuideCell(Icons.water_drop_outlined, 'WATER', water),
        _buildGuideCell(Icons.wb_sunny_outlined, 'SUNLIGHT', sun),
        _buildGuideCell(Icons.thermostat_outlined, 'TEMP', temp),
      ],
    );
  }

  Widget _buildGuideCell(IconData icon, String header, String content) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: AppColors.primaryGreen),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  header,
                  style: GoogleFonts.inter(
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[500],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  content,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF334155),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
