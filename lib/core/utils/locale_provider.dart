import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final localeProvider = StateNotifierProvider<LocaleNotifier, String>((ref) {
  return LocaleNotifier();
});

class LocaleNotifier extends StateNotifier<String> {
  LocaleNotifier() : super('en') {
    _loadLocale();
  }

  Future<void> _loadLocale() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final code = prefs.getString('app_locale');
      if (code == 'en' || code == 'bn') {
        state = code!;
      }
    } catch (e) {
      // Fallback if preferences fail (e.g. in test runs)
    }
  }

  Future<void> setLocale(String localeCode) async {
    if (state != localeCode && (localeCode == 'en' || localeCode == 'bn')) {
      state = localeCode;
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('app_locale', localeCode);
      } catch (e) {
        // Fallback if preferences fail
      }
    }
  }
}


final translationProvider = StateNotifierProvider<TranslationNotifier, Map<String, String>>((ref) {
  final currentLocale = ref.watch(localeProvider);
  return TranslationNotifier(currentLocale);
});

class TranslationNotifier extends StateNotifier<Map<String, String>> {
  final String locale;

  TranslationNotifier(this.locale) : super(locale == 'bn' ? _banglaFallback : _englishFallback) {
    _loadTranslations();
  }

  Future<void> _loadTranslations() async {
    try {
      final jsonString = await rootBundle.loadString('assets/$locale.json');
      final Map<String, dynamic> jsonMap = jsonDecode(jsonString);
      final mergedMap = Map<String, String>.from(locale == 'bn' ? _banglaFallback : _englishFallback);
      jsonMap.forEach((key, value) {
        mergedMap[key.toString().toLowerCase()] = value.toString();
      });
      state = mergedMap;
    } catch (e) {
      // Fallback is already set in the constructor
    }
  }
}

extension TranslationExtension on WidgetRef {
  String tr(String key) {
    final map = watch(translationProvider);
    final normalized = key.trim().toLowerCase();
    return map[normalized] ?? key;
  }
}

// Fallback maps to make sure everything loads instantly & works in tests
const Map<String, String> _englishFallback = {
  // Common
  "app_name": "PlantTree",
  "home": "Home",
  "explore": "Explore",
  "settings": "Settings",
  "tools": "Tools",
  "close": "Close",
  "allow": "Allow",

  // Home Screen
  "subtitle": "AI-Powered Plant Health Assistant",
  "spraying_conditions": "Spraying conditions",
  "moderate": "Moderate",
  "excellent": "Excellent",
  "poor (rain)": "Poor (Rain)",
  "poor (windy)": "Poor (Windy)",
  "until_12_am": "until 12 AM",
  "wind": "wind",
  "km_h": "km/h",
  "location_permission_msg": "Allow location access to see weather and spraying information for your area",
  "take_picture_step": "Take a\npicture",
  "see_diagnosis_step": "See\ndiagnosis",
  "get_medicine_step": "Get\nmedicine",
  "take_a_picture": "Take a picture",
  "spray_guide": "Spray guide",
  "fertilizer": "Fertilizer",
  "new_tag": "New",

  // Explore Screen
  "explore_crops": "Explore Crops",
  "explore_subtitle": "Planting guides and crop disease libraries",
  "search_plants": "Search plants...",
  "planting_guide": "Planting Guide",
  "common_diseases": "Common Diseases & Diagnosis",
  "symptoms": "Symptoms:",
  "management_guide": "Management Guide:",
  "no_common_diseases": "No common diseases loaded.",

  // Spray Guide Dialog
  "interactive_spray_guide": "Interactive Spray Guide",
  "crop_selection": "Crop selection:",
  "growth_stage": "Growth Stage:",
  "recommendation_header": "RECOMMENDATION:",
  "verify_safety": "Verify Safety",
  "seedling_early": "Seedling / Early",
  "flowering_bloom": "Flowering / Bloom",
  "fruiting_harvest": "Fruiting / Harvest",

  // Fertilizer Calculator
  "fertilizer_calculator": "Fertilizer Calculator",
  "target_crop": "Target Crop:",
  "fertilizer_feed_type": "Fertilizer Feed Type:",
  "garden_area_size": "Garden Area Size:",
  "calculated_dosage": "CALCULATED DOSAGE:",
  "application_guide": "Application Guide:",
  "calculate": "Calculate",

  // Settings
  "diagnostics_header": "Diagnostics Engine (TFLite)",
  "model_status": "Model Status:",
  "model_loaded": "Loaded (Active)",
  "model_standby": "Standby / Demo Mode",
  "asset_model": "Asset Model",
  "input_shape": "Input Shape",
  "output_classes": "Output classes",
  "mean_std": "Mean / Std Dev",
  "threshold": "Threshold",
  "diagnostics_sub": "App diagnostics and preferences",
  "app_language": "App Language",
  "select_language": "Select Language",
  "english": "English",
  "bangla": "Bangla",

  // Scan Screen
  "scan_leaf": "Scan Leaf",
  "analyzing_leaf": "Analyzing leaf...",
  "position_leaf": "Position leaf in frame",
  "leaf_loaded": "Leaf image loaded",
  "ai_examining": "Our AI is examining your plant",
  "take_photo_prompt": "Take a photo or upload from gallery",
  "select_crop_prompt": "Select the crop type below and click Scan",
  "take_photo": "Take Photo",
  "upload_gallery": "Upload from Gallery",
  "crop_type": "Crop Type:",
  "change_photo": "Change Photo",
  "leaf_preview": "Leaf Preview",

  // Results Screen
  "results": "Results",
  "no_results": "No results available",
  "detection_results": "Detection Results",
  "confidence_score": "Confidence Score",
  "description": "Description",
  "prevention_steps": "Prevention Steps",
  "scan_another": "Scan Another Leaf",
  "very_high_conf": "Very high confidence in this detection",
  "high_conf": "High confidence in this detection",
  "mod_conf": "Moderate confidence — consider re-scanning",
  "low_conf": "Low confidence — please try again with a clearer image",

  // Crops
  "apple": "Apple",
  "pepper": "Pepper",
  "corn": "Corn",
  "grape": "Grape",
  "peach": "Peach",
  "strawberry": "Strawberry",
  "tomato": "Tomato",

  "rosaceae family": "Rosaceae family",
  "solanaceae family": "Solanaceae family",
  "poaceae family": "Poaceae family",
  "vitaceae family": "Vitaceae family",

  "well-drained loam, ph 6.0-6.8": "Well-drained loam, pH 6.0-6.8",
  "rich loamy soil, ph 6.0-6.8": "Rich loamy soil, pH 6.0-6.8",
  "rich, well-draining loamy, ph 6.0-6.8": "Rich, well-draining loamy, pH 6.0-6.8",
  "deep, gravelly or sandy loam, ph 5.5-6.5": "Deep, gravelly or sandy loam, pH 5.5-6.5",
  "sandy loam, well-drained, ph 6.0-6.5": "Sandy loam, well-drained, pH 6.0-6.5",
  "deep sandy loam, rich in organic, ph 5.5-6.5": "Deep sandy loam, rich in organic, pH 5.5-6.5",
  "fertile, well-draining loamy, ph 6.2-6.8": "Fertile, well-draining loamy, pH 6.2-6.8",

  "moderate, 1 inch/week": "Moderate, 1 inch/week",
  "moderate, keep evenly moist": "Moderate, keep evenly moist",
  "high, 1.5-2 inches/week": "High, 1.5-2 inches/week",
  "low to moderate, water deeply": "Low to moderate, water deeply",
  "moderate, 1-2 inches/week": "Moderate, 1-2 inches/week",
  "regular deep watering, 1-2 inches/week": "Regular deep watering, 1-2 inches/week",

  "full sun, 6-8 hours daily": "Full sun, 6-8 hours daily",
  "full sun, 8+ hours daily": "Full sun, 8+ hours daily",
  "full sun, 8 hours daily": "Full sun, 8 hours daily",

  "15°c - 25°c": "15°C - 25°C",
  "21°c - 29°c": "21°C - 29°C",
  "20°c - 30°c": "20°C - 30°C",
  "15°c - 30°c": "15°C - 30°C",
  "18°c - 26°c": "18°C - 26°C",

  "npk 10-10-10 (balanced feed)": "NPK 10-10-10 (Balanced Feed)",
  "urea (46-0-0 nitrogen booster)": "Urea (46-0-0 Nitrogen Booster)",
  "organic compost (slow release)": "Organic Compost (Slow Release)",

  "npk_instruction": "Spread granules evenly around plant root lines. Keep it 4-6 inches away from the stalk. Dig gently into topsoil and water thoroughly.",
  "urea_instruction": "Nitrogen fertilizer! Apply in a narrow ring band around the plant canopy edge. Do not let granules touch crop leaves or stems. Water immediately to activate.",
  "compost_instruction": "Spread the compost layer (about 1 inch thick) over the topsoil. Gently mix with topsoil using a rake. Excellent organic slow release soil conditioner.",

  // Recommendations
  "apple_rec_0": "Apply Organic Copper Fungicide (Dilute 5ml per 1L of water). Spray early morning once every 14 days.",
  "apple_rec_1": "Apply Sulfur Dust or Neem Oil (Dilute 4ml per 1L of water). Avoid spraying during full bloom to protect bees.",
  "apple_rec_2": "Apply Captan Fungicide (Dilute 3g per 1L of water). Spray once every 12 days. Stop 7 days before harvest.",
  "pepper_rec_0": "Apply Copper Soap bactericide (Dilute 4ml per 1L of water) every 10 days to prevent leaf spots.",
  "pepper_rec_1": "Spray Organic Neem Oil solution (Dilute 5ml per 1L of water) every 7 days to control aphids & whiteflies.",
  "pepper_rec_2": "Apply Spinosad biological control (Dilute 2ml per 1L of water) for fruitworms. Spray evening after bees return.",
  "corn_rec_0": "No direct spray needed in early stages unless cutworms are active (Use Bt powder).",
  "corn_rec_1": "Apply preventive Chlorothalonil fungicide (Dilute 3ml per 1L) if gray leaf spot is active in the area.",
  "corn_rec_2": "No spray recommended near harvest. Keep stalks well watered.",
  "grape_rec_0": "Apply liquid copper fungicide (Dilute 5ml per 1L) to prevent black rot. Spray every 10 days.",
  "grape_rec_1": "Spray wettable sulfur (Dilute 4g per 1L) for powdery mildew control. Do not apply in temps above 30°C.",
  "grape_rec_2": "Apply organic potassium bicarbonate (Dilute 5g per 1L) for powdery mildew rescue treatment.",
  "peach_rec_0": "Spray Copper Fungicide before bud swell to prevent peach leaf curl. Single application.",
  "peach_rec_1": "Apply Spinosad or Neem Oil for thrips control. Spray evening after sunset.",
  "peach_rec_2": "Apply sulfur spray to protect ripening fruits from brown rot. Stop 3 days before picking.",
  "strawberry_rec_0": "Apply Copper bactericide (Dilute 4ml per 1L) for leaf scorch prevention in early spring.",
  "strawberry_rec_1": "Apply Insecticidal soap (Dilute 10ml per 1L) for spider mite control. Focus on leaf undersides.",
  "strawberry_rec_2": "Apply Organic Neem Oil (Dilute 5ml per 1L). Harvest only fully ripe berries 2 days post-spraying.",
  "tomato_rec_0": "Apply Copper Soap (Dilute 4ml per 1L) to prevent bacterial spot and early blight. Every 10 days.",
  "tomato_rec_1": "Spray organic Neem Oil (Dilute 5ml per 1L) or insecticidal soap for whitefly prevention. Weekly.",
  "tomato_rec_2": "Apply Bacillus thuringiensis (Bt) (Dilute 2g per 1L) to target tomato hornworms. Spray foliage fully.",

  "rain_alert": "🌧️ Weather alert: Rain is active at your location. Spraying is not recommended since chemicals will wash off.",
  "wind_alert": "⚠️ Wind alert: Wind speed is high ({wind} km/h). Spraying is unsafe due to pesticide drift.",
  "safe_alert": "✅ Conditions verified: Wind is safe ({wind} km/h) and no active rain. Safe to spray!",
  "demo_alert": "✅ Simulation verified: Estimated wind is 6.5 km/h. Safe to apply. (Allow location to verify real-time local wind)",

  // Diseases from labels.txt
  "apple apple scab": "Apple Apple Scab",
  "apple black rot": "Apple Black Rot",
  "apple cedar apple rust": "Apple Cedar Apple Rust",
  "apple healthy": "Apple Healthy",
  "blueberry healthy": "Blueberry Healthy",
  "cherry including sour powdery mildew": "Cherry Powdery Mildew",
  "cherry including sour healthy": "Cherry Healthy",
  "corn maize cercospora leaf spot gray leaf spot": "Corn Gray Leaf Spot",
  "corn maize common rust": "Corn Common Rust",
  "corn maize northern leaf blight": "Corn Northern Leaf Blight",
  "corn maize healthy": "Corn Healthy",
  "grape black rot": "Grape Black Rot",
  "grape esca black measles": "Grape Esca Black Measles",
  "grape leaf blight isariopsis leaf spot": "Grape Leaf Blight",
  "grape healthy": "Grape Healthy",
  "orange haunglongbing citrus greening": "Orange Citrus Greening",
  "peach bacterial spot": "Peach Bacterial Spot",
  "peach healthy": "Peach Healthy",
  "pepper bell bacterial spot": "Pepper Bacterial Spot",
  "pepper bell healthy": "Pepper Healthy",
  "potato early blight": "Potato Early Blight",
  "potato late blight": "Potato Late Blight",
  "potato healthy": "Potato Healthy",
  "raspberry healthy": "Raspberry Healthy",
  "soybean healthy": "Soybean Healthy",
  "squash powdery mildew": "Squash Powdery Mildew",
  "strawberry leaf scorch": "Strawberry Leaf Scorch",
  "strawberry healthy": "Strawberry Healthy",
  "tomato bacterial spot": "Tomato Bacterial Spot",
  "tomato early blight": "Tomato Early Blight",
  "tomato late blight": "Tomato Late Blight",
  "tomato leaf mold": "Tomato Leaf Mold",
  "tomato septoria leaf spot": "Tomato Septoria Leaf Spot",
  "tomato spider mites two spotted spider mite": "Tomato Spider Mites",
  "tomato target spot": "Tomato Target Spot",
  "tomato yellow leaf curl virus": "Tomato Yellow Leaf Curl Virus",
  "tomato mosaic virus": "Tomato Mosaic Virus",
  "tomato healthy": "Tomato Healthy",
  "background": "Background / Unknown",

  "severity": "Severity",
  "high": "High",
  "none": "None",

  "apple apple scab_symptoms": "Olive-green to black spots on leaves, which become velvety and brown over time. Fruit develops circular brown/black spots that can crack.",
  "apple apple scab_management": "Prune infected branches, clear fallen leaves, and apply copper-based fungicides during the green tip phase.",
  "apple black rot_symptoms": "Reddish-brown spots on leaves (frogeye leaf spot), sunken black cankers on branches, and dry rot on fruit with concentric zones.",
  "apple black rot_management": "Remove dead wood and mummified fruit, prune cankers, and apply protective fungicides during early season.",
  "apple cedar apple rust_symptoms": "Bright orange-yellow spots on upper leaf surfaces. Tubular spore cups develop on leaf undersides and fruit.",
  "apple cedar apple rust_management": "Remove nearby cedar trees (alternative host), plant rust-resistant cultivars, and apply fungicides at bud break.",
  "apple healthy_symptoms": "Leaves are lush green, firm, and free of blemishes. Tree shows good growth and fruit development.",
  "apple healthy_management": "Continue regular watering, pruning, fertilizing, and monitoring for pests.",
  "blueberry healthy_symptoms": "Deep green leaves with healthy stems and abundant flowering/fruiting. No visible leaf spots.",
  "blueberry healthy_management": "Maintain acidic soil pH (4.5-5.5), mulch root zone, and provide regular moisture.",
  "cherry including sour powdery mildew_symptoms": "White, powdery fungal patches on leaves and young shoots, causing leaf curling and stunted growth.",
  "cherry including sour powdery mildew_management": "Prune to improve airflow, avoid overhead watering, and apply sulfur-based fungicides.",
  "cherry including sour healthy_symptoms": "Foliage is green and vibrant. No signs of fungal leaf spots, powdery residue, or cankers.",
  "cherry including sour healthy_management": "Keep soil well-drained, prune annually for sunlight penetration, and apply fertilizer in spring.",
  "corn maize cercospora leaf spot gray leaf spot_symptoms": "Long, rectangular, grayish-brown lesions running parallel to leaf veins, eventually blending to kill entire leaves.",
  "corn maize cercospora leaf spot gray leaf spot_management": "Use resistant corn hybrids, practice crop rotation, tillage to bury residues, and apply foliar fungicides.",
  "corn maize common rust_symptoms": "Powdery, reddish-brown pustules on both upper and lower leaf surfaces, causing early leaf death.",
  "corn maize common rust_management": "Plant rust-resistant hybrids and apply fungicides early if disease pressure is high.",
  "corn maize northern leaf blight_symptoms": "Large, cigar-shaped, grayish-green to tan lesions on leaves, starting on lower leaves.",
  "corn maize northern leaf blight_management": "Rotate crops, till crop residue, plant resistant hybrids, and apply fungicides.",
  "corn maize healthy_symptoms": "Robust stalks with deep green, long leaves and healthy ear development. No lesions or rust pustules.",
  "corn maize healthy_management": "Maintain balanced nitrogen levels, manage weeds, and ensure proper irrigation.",
  "grape black rot_symptoms": "Small round brown spots on leaves. Berries shrivel into hard, black, wrinkled mummies.",
  "grape black rot_management": "Prune vines to open the canopy, remove all mummified berries, and apply fungicides from bud break through bloom.",
  "grape esca black measles_symptoms": "Tiger-stripe patterns on leaves (interveinal yellowing/browning). Berries develop dark spots or shrivel.",
  "grape esca black measles_management": "Protect pruning wounds, remove infected wood during dry weather, and use wound sealants.",
  "grape leaf blight isariopsis leaf spot_symptoms": "Dark brown, irregular spots on leaves, which may dry up and drop prematurely.",
  "grape leaf blight isariopsis leaf spot_management": "Apply copper fungicides, clean up fallen leaves in autumn, and improve canopy ventilation.",
  "grape healthy_symptoms": "Vibrant green leaves, strong vines, and clean grape clusters free of shriveled berries.",
  "grape healthy_management": "Prune during dormancy, fertilize based on soil tests, and maintain good weed control.",
  "orange haunglongbing citrus greening_symptoms": "Yellow mottled leaves, stunted growth, and small, misshapen, green, bitter-tasting fruit.",
  "orange haunglongbing citrus greening_management": "Control the Asian citrus psyllid vector, remove infected trees, and apply nutritional sprays to support vigor.",
  "peach bacterial spot_symptoms": "Water-soaked spots on leaves that turn brown and drop out (shot-hole). Fruit shows dark spots and cracks.",
  "peach bacterial spot_management": "Plant resistant varieties, avoid excess nitrogen, and apply copper sprays in early spring.",
  "peach healthy_symptoms": "Clean, unblemished leaves and smooth-skinned fruit. Stems show healthy new growth.",
  "peach healthy_management": "Thin fruit to prevent overload, prune for airflow, and monitor for borers.",
  "pepper bell bacterial spot_symptoms": "Small, circular, raised spots on leaves and fruit, causing leaf yellowing and defoliation.",
  "pepper bell bacterial spot_management": "Use pathogen-free seed, rotate crops, avoid overhead watering, and apply copper bactericides.",
  "pepper bell healthy_symptoms": "Dark green, upright plants with thick leaves and glossy, firm peppers.",
  "pepper bell healthy_management": "Keep soil evenly moist, fertilize with balanced nutrients, and stake plants for support.",
  "potato early blight_symptoms": "Dark spots with concentric rings (target board pattern) on older leaves. Lower leaves turn yellow.",
  "potato early blight_management": "Maintain high plant vigor, rotate crops, remove crop debris, and apply protective fungicides.",
  "potato late blight_symptoms": "Dark, water-soaked leaf lesions with white mold on undersides in wet weather. Tubers rot.",
  "potato late blight_management": "Plant certified disease-free seed, destroy volunteer potato plants, and apply preventive fungicides.",
  "potato healthy_symptoms": "Lush green canopy and healthy vine growth. No lesions or mold present.",
  "potato healthy_management": "Hill soil around plants, water at the base, and monitor closely during cool, wet periods.",
  "raspberry healthy_symptoms": "Healthy green leaves, upright canes, and bright, sweet fruit clusters.",
  "raspberry healthy_management": "Prune old fruiting canes, mulch to conserve moisture, and ensure good drainage.",
  "soybean healthy_symptoms": "Bushy, deep green foliage with healthy pod development and no leaf spots or rust.",
  "soybean healthy_management": "Ensure proper spacing, rotate with corn or wheat, and inoculate seeds with rhizobia.",
  "squash powdery mildew_symptoms": "White, powdery fungal spots spreading over leaves and stems, causing leaves to dry and wither.",
  "squash powdery mildew_management": "Ensure full sun exposure, prune for airflow, and apply potassium bicarbonate or neem oil sprays.",
  "strawberry leaf scorch_symptoms": "Purplish spots on leaves that enlarge and turn dark brown, giving leaves a scorched appearance.",
  "strawberry leaf scorch_management": "Plant resistant cultivars, renovate beds after harvest, and avoid overhead watering.",
  "strawberry healthy_symptoms": "Bright green leaves, clean white flowers, and plump, red berries.",
  "strawberry healthy_management": "Mulch with straw, remove runners to maintain spacing, and water consistently.",
  "tomato bacterial spot_symptoms": "Small, dark, greasy-looking spots on leaves and stems. Fruit develops raised, scabby spots.",
  "tomato bacterial spot_management": "Use clean seed, rotate crops, avoid overhead watering, and apply copper-based sprays.",
  "tomato early blight_symptoms": "Concentric black spots on older leaves, leading to yellowing and drop. Stem lesions can girdle seedlings.",
  "tomato early blight_management": "Mulch soil, prune lower leaves, rotate crops, and apply chlorothalonil or copper fungicides.",
  "tomato late blight_symptoms": "Rapidly spreading large dark brown lesions on leaves and fruit with white fuzzy mold underneath in humid conditions.",
  "tomato late blight_management": "Remove and destroy infected plants immediately, choose resistant varieties, and apply preventive copper sprays.",
  "tomato leaf mold_symptoms": "Pale green to yellow spots on upper leaf surfaces, with olive-green velvety mold on leaf undersides.",
  "tomato leaf mold_management": "Reduce humidity in greenhouses, improve airflow, and use resistant cultivars.",
  "tomato septoria leaf spot_symptoms": "Numerous small, circular spots with dark borders and grey centers on lower leaves, causing severe defoliation.",
  "tomato septoria leaf spot_management": "Avoid overhead watering, destroy infected crop residue, mulch, and apply fungicides.",
  "tomato spider mites two spotted spider mite_symptoms": "Fine yellow speckling on leaves, followed by bronzing, drying, and fine webbing on leaves.",
  "tomato spider mites two spotted spider mite_management": "Spray with insecticidal soap, introduce predatory mites, and keep plants well-watered.",
  "tomato target spot_symptoms": "Small brown spots with concentric circles (targets) on leaves and fruit, causing premature leaf drop.",
  "tomato target spot_management": "Space plants well, prune lower foliage, and apply protective fungicides.",
  "tomato yellow leaf curl virus_symptoms": "Stunted growth, leaves curl upwards and inwards, turning yellow at margins. Reduced fruit set.",
  "tomato yellow leaf curl virus_management": "Control silverleaf whitefly vectors with row covers, yellow sticky traps, or insecticides, and plant resistant varieties.",
  "tomato mosaic virus_symptoms": "Mottling light and dark green patterns on leaves, leaf distortion (shoestringing), and uneven ripening of fruit.",
  "tomato mosaic virus_management": "Sanitize tools, wash hands with soap, plant resistant cultivars, and remove infected plants.",
  "tomato healthy_symptoms": "Robust vines, dark green leaves, and vibrant red fruit with no spots, curling, or molds.",
  "tomato healthy_management": "Prune suckers, stake plants, water deeply at the base, and fertilize regularly.",
  "background_symptoms": "The image does not show a recognizable plant leaf, or is out of focus.",
  "background_management": "Please point the camera closer and focus on an infected plant leaf.",
  "turn_on_internet": "Turn on the internet",
  "exit_app": "Exit App",
  "exit_confirmation": "Are you sure you want to exit the app?",
  "cancel": "Cancel",
  "exit": "Exit"
};

const Map<String, String> _banglaFallback = {
  // Common
  "app_name": "প্ল্যান্ট ট্রি",
  "home": "হোম",
  "explore": "এক্সপ্লোর",
  "settings": "সেটিংস",
  "tools": "সরঞ্জাম",
  "close": "বন্ধ করুন",
  "allow": "অনুমতি দিন",

  // Home Screen
  "subtitle": "এআই-চালিত উদ্ভিদের স্বাস্থ্য সহকারী",
  "spraying_conditions": "স্প্রে করার অবস্থা",
  "moderate": "moderate",
  "excellent": "চমৎকার",
  "poor (rain)": "খারাপ (বৃষ্টি)",
  "poor (windy)": "খারাপ (ঝড়ো হাওয়া)",
  "until_12_am": "রাত ১২টা পর্যন্ত",
  "wind": "বাতাস",
  "km_h": "কিমি/ঘণ্টা",
  "location_permission_msg": "আপনার এলাকার আবহাওয়া এবং স্প্রে করার তথ্য দেখতে লোকেশন অ্যাক্সেসের অনুমতি দিন",
  "take_picture_step": "ছবি\nতুলুন",
  "see_diagnosis_step": "রোগের বিবরণ\nদেখুন",
  "get_medicine_step": "প্রতিকার\nজানুন",
  "take_a_picture": "ছবি তুলুন",
  "spray_guide": "স্প্রে নির্দেশিকা",
  "fertilizer": "সার হিসাবকারী",
  "new_tag": "নতুন",

  // Explore Screen
  "explore_crops": "ফসল অন্বেষণ",
  "explore_subtitle": "রোপণ নির্দেশিকা এবং ফসলের রোগ লাইব্রেরি",
  "search_plants": "উদ্ভিদ অনুসন্ধান...",
  "planting_guide": "রোপণ নির্দেশিকা",
  "common_diseases": "সাধারণ রোগ ও রোগ নির্ণয়",
  "symptoms": "লক্ষণসমূহ:",
  "management_guide": "ব্যবস্থাপনা নির্দেশিকা:",
  "no_common_diseases": "কোন সাধারণ রোগ পাওয়া যায়নি।",

  // Spray Guide Dialog
  "interactive_spray_guide": "ইন্টারেক্টিভ স্প্রে নির্দেশিকা",
  "crop_selection": "ফসল নির্বাচন:",
  "growth_stage": "বৃদ্ধির ধাপ:",
  "recommendation_header": "সুপারিশ:",
  "verify_safety": "নিরাপত্তা যাচাই করুন",
  "seedling_early": "চারাগাছ / প্রাথমিক",
  "flowering_bloom": "ফুল ফোটার সময়",
  "fruiting_harvest": "ফল ধরা / ফসল সংগ্রহ",

  // Fertilizer Calculator
  "fertilizer_calculator": "সার প্রয়োগের হিসাব",
  "target_crop": "টার্গেট ফসল:",
  "fertilizer_feed_type": "সারের ধরণ:",
  "garden_area_size": "বাগানের আকার:",
  "calculated_dosage": "হিসাবকৃত পরিমাণ:",
  "application_guide": "প্রয়োগ নির্দেশিকা:",
  "calculate": "হিসাব করুন",

  // Settings
  "diagnostics_header": "ডায়াগনস্টিকস ইঞ্জিন (TFLite)",
  "model_status": "মডেল অবস্থা:",
  "model_loaded": "লোডেড (সক্রিয়)",
  "model_standby": "স্ট্যান্ডবাই / ডেমো মোড",
  "asset_model": "অ্যাসেট মডেল",
  "input_shape": "ইনপুট শেইপ",
  "output_classes": "আউটপুট ক্লাস",
  "mean_std": "মিন / স্ট্যান্ডার্ড ডেভিয়েশন",
  "threshold": "থ্রেশহোল্ড",
  "diagnostics_sub": "অ্যাপ ডায়াগনস্টিকস এবং সেটিংস",
  "app_language": "অ্যাপের ভাষা",
  "select_language": "ভাষা নির্বাচন করুন",
  "english": "ইংরেজি",
  "bangla": "বাংলা",

  // Scan Screen
  "scan_leaf": "পাতা স্ক্যান করুন",
  "analyzing_leaf": "পাতা বিশ্লেষণ করা হচ্ছে...",
  "position_leaf": "ফ্রেমের মধ্যে পাতা রাখুন",
  "leaf_loaded": "পাতার ছবি লোড হয়েছে",
  "ai_examining": "আমাদের এআই আপনার উদ্ভিদটি পরীক্ষা করছে",
  "take_photo_prompt": "একটি ছবি তুলুন বা গ্যালারি থেকে আপলোড করুন",
  "select_crop_prompt": "নিচে ফসলের ধরন নির্বাচন করুন এবং স্ক্যান ক্লিক করুন",
  "take_photo": "ছবি তুলুন",
  "upload_gallery": "গ্যালারি থেকে আপলোড",
  "crop_type": "ফসলের ধরণ:",
  "change_photo": "ছবি পরিবর্তন করুন",
  "leaf_preview": "পাতার প্রিভিউ",

  // Results Screen
  "results": "ফলাফল",
  "no_results": "কোন ফলাফল পাওয়া যায়নি",
  "detection_results": "সনাক্তকরণের ফলাফল",
  "confidence_score": "নিশ্চয়তার স্কোর",
  "description": "রোগের বিবরণ",
  "prevention_steps": "প্রতিরোধের ধাপসমূহ",
  "scan_another": "অন্য পাতা স্ক্যান করুন",
  "very_high_conf": "সনাক্তকরণে খুব উচ্চ নিশ্চয়তা রয়েছে",
  "high_conf": "সনাক্তকরণে উচ্চ নিশ্চয়তা রয়েছে",
  "mod_conf": "মাঝারি নিশ্চয়তা — পুনরায় স্ক্যান করার কথা বিবেচনা করুন",
  "low_conf": "কম নিশ্চয়তা — অনুগ্রহ করে পরিষ্কার ছবি দিয়ে পুনরায় চেষ্টা করুন",

  // Crops
  "apple": "আপেল",
  "pepper": "মরিচ",
  "corn": "ভুট্টা",
  "grape": "আঙুর",
  "peach": "পিচ",
  "strawberry": "স্ট্রবেরি",
  "tomato": "টমেটো",

  "rosaceae family": "গোলাপ পরিবার (রোসেসি)",
  "solanaceae family": "আলু পরিবার (সোলোনেসি)",
  "poaceae family": "ঘাস পরিবার (পোয়েসি)",
  "vitaceae family": "আঙুর পরিবার (ভিটেসি)",

  "well-drained loam, ph 6.0-6.8": "নিকাশযুক্ত দোআঁশ মাটি, পিএইচ ৬.০-৬.৮",
  "rich loamy soil, ph 6.0-6.8": "উর্বর দোআঁশ মাটি, পিএইচ ৬.০-৬.৮",
  "rich, well-draining loamy, ph 6.0-6.8": "উর্বর ও সুনিষ্কাশিত দোআঁশ, পিএইচ ৬.০-৬.৮",
  "deep, gravelly or sandy loam, ph 5.5-6.5": "গভীর, নুড়িযুক্ত বা বেলে দোআঁশ, পিএইচ ৫.৫-৬.৫",
  "sandy loam, well-drained, ph 6.0-6.5": "বেলে দোআঁশ, সুনিষ্কাশিত, পিএইচ ৬.০-৬.৫",
  "deep sandy loam, rich in organic, ph 5.5-6.5": "জৈব সমৃদ্ধ গভীর বেলে দোআঁশ, পিএইচ ৫.৫-৬.৫",
  "fertile, well-draining loamy, ph 6.2-6.8": "উর্বর ও সুনিষ্কাশিত দোআঁশ, পিএইচ ৬.২-৬.৮",

  "moderate, 1 inch/week": "পরিমিত, সপ্তাহে ১ ইঞ্চি",
  "moderate, keep evenly moist": "পরিমিত, আর্দ্রতা বজায় রাখুন",
  "high, 1.5-2 inches/week": "বেশি, সপ্তাহে ১.৫-২ ইঞ্চি",
  "low to moderate, water deeply": "কম থেকে পরিমিত, গোড়ায় গভীর সেচ দিন",
  "moderate, 1-2 inches/week": "পরিমিত, সপ্তাহে ১-২ ইঞ্চি",
  "regular deep watering, 1-2 inches/week": "নিয়মিত গভীর সেচ, সপ্তাহে ১-২ ইঞ্চি",

  "full sun, 6-8 hours daily": "পূর্ণ সূর্যালোক, প্রতিদিন ৬-৮ ঘণ্টা",
  "full sun, 8+ hours daily": "পূর্ণ সূর্যালোক, প্রতিদিন ৮+ ঘণ্টা",
  "full sun, 8 hours daily": "পূর্ণ সূর্যালোক, প্রতিদিন ৮ ঘণ্টা",

  "15°c - 25°c": "১৫°সে. - ২৫°সে.",
  "21°c - 29°c": "২১°সে. - ২৯°সে.",
  "20°c - 30°c": "২০°সে. - ৩০°সে.",
  "15°c - 30°c": "১৫°সে. - ৩০°সে.",
  "18°c - 26°c": "১৮°সে. - ২৬°সে.",

  "npk 10-10-10 (balanced feed)": "এনপিকে ১০-১০-১০ (সুষম খাদ্য)",
  "urea (46-0-0 nitrogen booster)": "ইউরিয়া (৪৬-০-০ নাইট্রোজেন বুস্টার)",
  "organic compost (slow release)": "জৈব কম্পোস্ট (ধীর নিঃসরণ)",

  "npk_instruction": "সারগুলো গাছের গোড়ার চারিদিকে সমানভাবে ছড়িয়ে দিন। গাছের কান্ড বা গোড়া থেকে ৪-৬ ইঞ্চি দূরে রাখুন। আলতো করে মাটি কুপিয়ে মিশিয়ে দিন এবং পর্যাপ্ত পানি দিন।",
  "urea_instruction": "নাইট্রোজেন সার! গাছের উপরিভাগের ক্যানপির ঠিক নিচ বরাবর সরু রিং করে প্রয়োগ করুন। সারের দানা যেন গাছের পাতা বা কান্ডে না লাগে। সার সক্রিয় করতে অবিলম্বে পানি দিন।",
  "compost_instruction": "মাটির উপরিভাগে প্রায় ১ ইঞ্চি পুরু জৈব সারের স্তর ছড়িয়ে দিন। এরপর একটি আলতো হাত লাঙল বা কোদাল দিয়ে মাটির সাথে হালকাভাবে মিশিয়ে দিন। এটি একটি চমৎকার ধীর নিঃসরণকারী জৈব সার।",

  // Recommendations
  "apple_rec_0": "অর্গানিক কপার ছত্রাকনাশক প্রয়োগ করুন (প্রতি ১ লিটার পানিতে ৫ মিলি)। প্রতি ১৪ দিনে একবার খুব ভোরে স্প্রে করুন।",
  "apple_rec_1": "সালফার ডাস্ট বা নিম তেল প্রয়োগ করুন (প্রতি ১ লিটার পানিতে ৪ মিলি)। মৌমাছিদের সুরক্ষায় ফুল ফোটার সময় স্প্রে করা এড়িয়ে চলুন।",
  "apple_rec_2": "ক্যাপটান ছত্রাকনাশক প্রয়োগ করুন (প্রতি ১ লিটার পানিতে ৩ গ্রাম)। প্রতি ১২ দিনে একবার স্প্রে করুন। ফসল তোলার ৭ দিন আগে স্প্রে করা বন্ধ করুন।",
  "pepper_rec_0": "পাতার দাগ প্রতিরোধে প্রতি ১০ দিন পর পর কপার সোপ ব্যাকটেরিসাইড (প্রতি ১ লিটার পানিতে ৪ মিলি) প্রয়োগ করুন।",
  "pepper_rec_1": "জাবপোকা ও সাদা মাছি দমনে প্রতি ৭ দিন পর পর অর্গানিক নিম তেলের দ্রবণ (প্রতি ১ লিটার পানিতে ৫ মিলি) স্প্রে করুন।",
  "pepper_rec_2": "ফল ছিদ্রকারী পোকার জন্য স্পিনোস্যাড জৈবিক দমন (প্রতি ১ লিটার পানিতে ২ মিলি) প্রয়োগ করুন। মৌমাছিরা ফিরে যাওয়ার পর সন্ধ্যায় স্প্রে করুন।",
  "corn_rec_0": "কাটা পোকার আক্রমণ না হলে প্রাথমিক পর্যায়ে সরাসরি স্প্রে করার প্রয়োজন নেই (বিটি পাউডার ব্যবহার করুন)।",
  "corn_rec_1": "এলাকায় গ্রে লিফ স্পট রোগের প্রকোপ থাকলে প্রতিরোধমূলক ক্লোরোথ্যালোনিল ছত্রাকনাশক (প্রতি ১ লিটারে ৩ মিলি) প্রয়োগ করুন।",
  "corn_rec_2": "ফসল তোলার কাছাকাছি সময়ে কোনো স্প্রে করার প্রয়োজন নেই। গাছের গোড়ায় পর্যাপ্ত পানি দিন।",
  "grape_rec_0": "ব্ল্যাক রট বা কালো পচন রোগ প্রতিরোধে তরল কপার ছত্রাকনাশক (প্রতি ১ লিটারে ৫ মিলি) প্রয়োগ করুন। প্রতি ১০ দিন পর পর স্প্রে করুন।",
  "grape_rec_1": "পাউডারি মিলডিউ দমনে ভেজানো সালফার (প্রতি ১ লিটারে ৪ গ্রাম) স্প্রে করুন। ৩০ ডিগ্রি সেলসিয়াসের বেশি তাপমাত্রায় প্রয়োগ করবেন না।",
  "grape_rec_2": "পাউডারি মিলডিউ রোগ থেকে উদ্ধারে অর্গানিক পটাসিয়াম বাইকার্বোনেট (প্রতি ১ লিটারে ৫ গ্রাম) প্রয়োগ করুন।",
  "peach_rec_0": "পিচ গাছের পাতা কোঁকড়ানো রোগ প্রতিরোধে কুঁড়ি ফোটার আগেই কপার ছত্রাকনাশক স্প্রে করুন। মাত্র একবার প্রয়োগ করুন।",
  "peach_rec_1": "থ্রিপস দমনে স্পিনোস্যাড বা নিম তেল প্রয়োগ করুন। সূর্যাস্তের পর সন্ধ্যায় স্প্রে করুন।",
  "peach_rec_2": "পাকা ফলকে বাদামী পচন রোগ থেকে রক্ষা করতে সালফার স্প্রে করুন। ফল তোলার ৩ দিন আগে বন্ধ করুন।",
  "strawberry_rec_0": "বসন্তের শুরুতে পাতার ঝলসানো রোগ প্রতিরোধে কপার ব্যাকটেরিসাইড (প্রতি ১ লিটারে ৪ মিলি) প্রয়োগ করুন।",
  "strawberry_rec_1": "মাকড়সা বা মাইট দমনে কীটনাশক সাবান (প্রতি ১ লিটারে ১০ মিলি) প্রয়োগ করুন। পাতার নিচের অংশে বেশি মনোযোগ দিন।",
  "strawberry_rec_2": "অর্গানিক নিম তেল (প্রতি ১ লিটারে ৫ মিলি) প্রয়োগ করুন। স্প্রে করার ২ দিন পর শুধুমাত্র সম্পূর্ণ পাকা ফল সংগ্রহ করুন।",
  "tomato_rec_0": "ব্যাকটেরিয়াল স্পট এবং আর্লি ব্লাইট প্রতিরোধে কপার সোপ (প্রতি ১ লিটারে ৪ মিলি) প্রয়োগ করুন। প্রতি ১০ দিন পর পর।",
  "tomato_rec_1": "সাদা মাছি প্রতিরোধে অর্গানিক নিম তেল (প্রতি ১ লিটারে ৫ মিলি) বা সাবান পানি স্প্রে করুন। প্রতি সপ্তাহে।",
  "tomato_rec_2": "টমেটোর হর্নওয়ার্ম পোকা দমনে ব্যাসিলাস থুরিনজিয়েনসিস (বিটি) (প্রতি ১ লিটারে ২ গ্রাম) প্রয়োগ করুন। পুরো পাতায় ভালোভাবে স্প্রে করুন।",

  "rain_alert": "🌧️ আবহাওয়া সতর্কবার্তা: আপনার এলাকায় বৃষ্টি হচ্ছে। স্প্রে করার সুপারিশ করা হচ্ছে না কারণ রাসায়নিক ধুয়ে যাবে।",
  "wind_alert": "⚠️ বাতাস সতর্কবার্তা: বাতাসের গতিবেগ বেশি ({wind} কিমি/ঘণ্টা)। কীটনাশক ছড়িয়ে পড়ার কারণে স্প্রে করা নিরাপদ নয়।",
  "safe_alert": "✅ অবস্থা যাচাই করা হয়েছে: বাতাস নিরাপদ ({wind} কিমি/ঘণ্টা) এবং কোনো সক্রিয় বৃষ্টি নেই। স্প্রে করা নিরাপদ!",
  "demo_alert": "✅ সিমুলেশন যাচাই করা হয়েছে: আনুমানিক বাতাস ৬.৫ কিমি/ঘণ্টা। প্রয়োগ করা নিরাপদ। (প্রকৃত স্থানীয় বায়ু যাচাই করতে লোকেশন অনুমতি দিন)",

  // Diseases from labels.txt
  "apple apple scab": "আপেল স্ক্যাব",
  "apple black rot": "আপেল ব্ল্যাক রট (কালো পচন)",
  "apple cedar apple rust": "আপেল মরিচা রোগ (সিডার অ্যাপেল রাস্ট)",
  "apple healthy": "আপেল সুস্থ গাছ",
  "blueberry healthy": "ব্লুবেরি সুস্থ গাছ",
  "cherry including sour powdery mildew": "চেরি পাউডারি মিলডিউ",
  "cherry including sour healthy": "চেরি সুস্থ গাছ",
  "corn maize cercospora leaf spot gray leaf spot": "ভুট্টা সারকোস্পোরা পাতার দাগ",
  "corn maize common rust": "ভুট্টা মরিচা রোগ",
  "corn maize northern leaf blight": "ভুট্টা পাতা ঝলসানো রোগ (নর্দার্ন লিফ ব্লাইট)",
  "corn maize healthy": "ভুট্টা সুস্থ গাছ",
  "grape black rot": "আঙুর ব্ল্যাক রট (কালো পচন)",
  "grape esca black measles": "আঙুর এসকা (কালো দাগ)",
  "grape leaf blight isariopsis leaf spot": "আঙুর পাতার ঝলসানো রোগ",
  "grape healthy": "আঙুর সুস্থ গাছ",
  "orange haunglongbing citrus greening": "কমলালেবু সাইট্রাস গ্রিনিং",
  "peach bacterial spot": "পিচ ব্যাকটেরিয়াল স্পট",
  "peach healthy": "পিচ সুস্থ গাছ",
  "pepper bell bacterial spot": "মিষ্টি মরিচ ব্যাকটেরিয়াল স্পট",
  "pepper bell healthy": "মিষ্টি মরিচ সুস্থ গাছ",
  "potato early blight": "আলু আগাম ধসা রোগ (আর্লি ব্লাইট)",
  "potato late blight": "আলু নাভি ধসা রোগ (লেট ব্লাইট)",
  "potato healthy": "আলু সুস্থ গাছ",
  "raspberry healthy": "রাসবেরি সুস্থ গাছ",
  "soybean healthy": "সয়াবিন সুস্থ গাছ",
  "squash powdery mildew": "স্কোয়াশ পাউডারি মিলডিউ",
  "strawberry leaf scorch": "স্ট্রবেরি পাতার ঝলসানো রোগ (লিফ স্কর্চ)",
  "strawberry healthy": "স্ট্রবেরি সুস্থ গাছ",
  "tomato bacterial spot": "টমেটো ব্যাকটেরিয়াল স্পট",
  "tomato early blight": "টমেটো আগাম ধসা রোগ (আর্লি ব্লাইট)",
  "tomato late blight": "টমেটো নাভি ধসা রোগ (লেট ব্লাইট)",
  "tomato leaf mold": "টমেটো পাতার ছাতা রোগ (লিফ মোল্ড)",
  "tomato septoria leaf spot": "টমেটো সেপটোরিয়া পাতার দাগ রোগ",
  "tomato spider mites two spotted spider mite": "টমেটো লাল মাকড়সা পোকার আক্রমণ",
  "tomato target spot": "টমেটো টার্গেট স্পট (পাতার চক্রাকার দাগ)",
  "tomato yellow leaf curl virus": "টমেটো হলুদ পাতা মোড়ানো রোগ",
  "tomato mosaic virus": "টমেটো মোজাইক ভাইরাস",
  "tomato healthy": "টমেটো সুস্থ গাছ",
  "background": "অজানা উদ্ভিদ বা ব্যাকগ্রাউন্ড",

  "severity": "তীব্রতা",
  "high": "উচ্চ",
  "none": "নেই",

  "apple apple scab_symptoms": "পাতায় জলপাই-সবুজ থেকে কালো দাগ দেখা যায়, যা সময়ের সাথে সাথে মখমলের মতো এবং বাদামী হয়ে যায়। ফলের উপর গোলাকার বাদামী/কালো দাগ তৈরি হয় যা ফেটে যেতে পারে।",
  "apple apple scab_management": "আক্রান্ত ডাল ছাঁটাই করুন, ঝরে পড়া পাতা পরিষ্কার করুন এবং সবুজ কুঁড়ি আসার সময় তামা (কপার) ভিত্তিক ছত্রাকনাশক প্রয়োগ করুন।",
  "apple black rot_symptoms": "পাতায় লালচে-বাদামী দাগ (frogeye leaf spot), ডালে দেবে যাওয়া কালো ক্ষত (ক্যানকার) এবং ফলের উপর সমকেন্দ্রিক বলয় বিশিষ্ট শুকনো পচন দেখা যায়।",
  "apple black rot_management": "মৃত ডালপালা এবং শুকিয়ে যাওয়া ফল অপসারণ করুন, ক্ষতস্থান ছাঁটাই করুন এবং মৌসুমের শুরুতে সুরক্ষামূলক ছত্রাকনাশক প্রয়োগ করুন।",
  "apple cedar apple rust_symptoms": "পাতার উপরের পৃষ্ঠে উজ্জ্বল কমলা-হলুদ দাগ। পাতার নিচের পৃষ্ঠে এবং ফলে নলাকার স্পোর কাপ তৈরি হয়।",
  "apple cedar apple rust_management": "কাছাকাছি থাকা সিডার গাছ (বিকল্প হোস্ট) অপসারণ করুন, মরিচা-প্রতিরোধী জাত রোপণ করুন এবং কুঁড়ি ফোটার সময় ছত্রাকনাশক প্রয়োগ করুন।",
  "apple healthy_symptoms": "পাতাগুলো ঘন সবুজ, সতেজ এবং দাগহীন। গাছটি ভালো বৃদ্ধি এবং ফলনের লক্ষণ দেখাচ্ছে।",
  "apple healthy_management": "নিয়মিত সেচ দিন, ছাঁটাই করুন, সার দিন এবং পোকামাকড়ের উপদ্রব পর্যবেক্ষণ করা চালিয়ে যান।",
  "blueberry healthy_symptoms": "সুস্থ ডালপালা এবং প্রচুর ফুল/ফল সহ গাঢ় সবুজ পাতা। কোনো দৃশ্যমান পাতার দাগ নেই।",
  "blueberry healthy_management": "মাটির অম্লীয় পিএইচ (৪.৫-৫.৫) বজায় রাখুন, শিকড়ের চারপাশ মালচ করুন এবং নিয়মিত আর্দ্রতা প্রদান করুন।",
  "cherry including sour powdery mildew_symptoms": "পাতা এবং কচি ডালে সাদা, গুঁড়ো ছত্রাকের প্রলেপ দেখা যায়, যা পাতা কুঁকড়ে যাওয়া এবং গাছের বৃদ্ধি ব্যাহত করে।",
  "cherry including sour powdery mildew_management": "বাতাস চলাচল বৃদ্ধির জন্য ছাঁটাই করুন, গাছের উপর থেকে পানি দেওয়া এড়িয়ে চলুন এবং সালফার-ভিত্তিক ছত্রাকনাশক প্রয়োগ করুন।",
  "cherry including sour healthy_symptoms": "গাছের পাতা সবুজ ও প্রাণবন্ত। ছত্রাকজনিত পাতার দাগ, গুঁড়ো প্রলেপ বা ক্ষতের কোনো লক্ষণ নেই।",
  "cherry including sour healthy_management": "মাটি সুনিষ্কাশিত রাখুন, সূর্যালোক প্রবেশের জন্য প্রতি বছর ছাঁটাই করুন এবং বসন্তকালে সার প্রয়োগ করুন।",
  "corn maize cercospora leaf spot gray leaf spot_symptoms": "পাতার শিরার সমান্তরালে লম্বা, আয়তাকার, ধূসর-বাদামী ক্ষত দেখা যায়, যা পরবর্তীতে পুরো পাতাকে মেরে ফেলে।",
  "corn maize cercospora leaf spot gray leaf spot_management": "প্রতিরোধী জাতের ভুট্টা চাষ করুন, ফসল পর্যায়ক্রমিক আবর্তন করুন, ফসলের অবশিষ্টাংশ পুড়িয়ে বা মাটিতে মিশিয়ে দিন এবং ছত্রাকনাশক স্প্রে করুন।",
  "corn maize common rust_symptoms": "পাতার উপরের এবং নিচের উভয় পৃষ্ঠে লালচে-বাদামী গুঁড়ো ফোসকা (পাস্টুল) দেখা যায়, যার ফলে পাতা অকালেই মারা যায়।",
  "corn maize common rust_management": "মরিচা-প্রতিরোধী জাতের বীজ ব্যবহার করুন এবং রোগের প্রকোপ বেশি হলে শুরুর দিকেই ছত্রাকনাশক প্রয়োগ করুন।",
  "corn maize northern leaf blight_symptoms": "পাতার ওপর বড়, চুরুট আকৃতির, ধূসর-সবুজ বা তামাটে রঙের ক্ষত দেখা যায়, যা সাধারণত নিচের পাতা থেকে শুরু হয়।",
  "corn maize northern leaf blight_management": "ফসল পর্যায়ক্রমিক আবর্তন করুন, ফসলের অবশিষ্টাংশ পরিষ্কার করুন, প্রতিরোধী জাত রোপণ করুন এবং ছত্রাকনাশক প্রয়োগ করুন।",
  "corn maize healthy_symptoms": "গাঢ় সবুজ রঙের দীর্ঘ পাতা এবং চমৎকার মোচা সহ শক্তিশালী কান্ড। কোনো ক্ষত বা মরিচা রোগ নেই।",
  "corn maize healthy_management": "সুষম নাইট্রোজেনের মাত্রা বজায় রাখুন, আগাছা দমন করুন এবং সঠিক সেচ নিশ্চিত করুন।",
  "grape black rot_symptoms": "পাতায় ছোট গোলাকার বাদামী দাগ পড়ে। আঙুরগুলো শুকিয়ে শক্ত, কালো এবং কুঁচকে যাওয়া মমিতে পরিণত হয়।",
  "grape black rot_management": "লতাগুলো ছাঁটাই করে আলো-বাতাসের ব্যবস্থা করুন, সমস্ত শুকিয়ে যাওয়া মমি আঙুর অপসারণ করুন এবং কুঁড়ি থেকে ফুল ফোটা পর্যন্ত ছত্রাকনাশক দিন।",
  "grape esca black measles_symptoms": "পাতায় বাঘের মতো ডোরাকাটা দাগ (শিরার মধ্যবর্তী অংশ হলুদ/বাদামী হওয়া)। আঙুরগুলোতে কালো দাগ পড়ে বা কুঁকড়ে যায়।",
  "grape esca black measles_management": "ছাঁটাইয়ের ক্ষতস্থান সুরক্ষিত রাখুন, শুকনো আবহাওয়ায় আক্রান্ত কাঠ কেটে ফেলুন এবং ক্ষত নিরাময়কারী প্রলেপ ব্যবহার করুন।",
  "grape leaf blight isariopsis leaf spot_symptoms": "পাতায় গাঢ় বাদামী, অনিয়মিত দাগ পড়ে, যার ফলে পাতা শুকিয়ে অকালেই ঝরে যেতে পারে।",
  "grape leaf blight isariopsis leaf spot_management": "কপার ছত্রাকনাশক প্রয়োগ করুন, শরৎকালে ঝরে পড়া পাতা পরিষ্কার করুন এবং লতার চারপাশের বাতাস চলাচল উন্নত করুন।",
  "grape healthy_symptoms": "প্রাণবন্ত সবুজ পাতা, শক্তিশালী লতা এবং শুকিয়ে যাওয়া মমি মুক্ত পরিষ্কার আঙুরের ছড়া।",
  "grape healthy_management": "সুপ্ত অবস্থায় ছাঁটাই করুন, মাটি পরীক্ষার ভিত্তিতে সার প্রয়োগ করুন এবং সঠিক আগাছা নিয়ন্ত্রণ বজায় রাখুন।",
  "orange haunglongbing citrus greening_symptoms": "হলুদ ছোপ ছোপ পাতা, রুদ্ধ বৃদ্ধি এবং ছোট, বিকৃত, সবুজ ও তেতো স্বাদের ফল।",
  "orange haunglongbing citrus greening_management": "রোগবাহী এশিয়ান সাইট্রাস সাইলিড পোকা নিয়ন্ত্রণ করুন, আক্রান্ত গাছ কেটে ফেলুন এবং গাছের শক্তি বৃদ্ধির জন্য পুষ্টি স্প্রে করুন।",
  "peach bacterial spot_symptoms": "পাতায় পানি-সিক্ত দাগ পড়ে যা পরবর্তীতে বাদামী হয়ে ঝরে যায় (shot-hole)। ফলের ওপর কালো দাগ ও ফাটল দেখা দেয়।",
  "peach bacterial spot_management": "প্রতিরোধী জাত রোপণ করুন, অতিরিক্ত নাইট্রোজেন এড়িয়ে চলুন এবং বসন্তের শুরুতে কপার স্প্রে প্রয়োগ করুন।",
  "peach healthy_symptoms": "পরিষ্কার, দাগহীন পাতা এবং মসৃণ খোসা বিশিষ্ট ফল। কান্ডে সুস্থ নতুন বৃদ্ধির লক্ষণ রয়েছে।",
  "peach healthy_management": "অতিরিক্ত ভার এড়াতে ফল পাতলা করুন, বাতাস চলাচলের জন্য ছাঁটাই করুন এবং কান্ডের পোকা পর্যবেক্ষণ করুন।",
  "pepper bell bacterial spot_symptoms": "পাতা ও ফলের উপর ছোট, গোলাকার, উঁচু দাগ দেখা যায়, যা পাতা হলুদ হওয়া এবং অকাল পাতা ঝরার কারণ হয়।",
  "pepper bell bacterial spot_management": "রোগমুক্ত বীজ ব্যবহার করুন, ফসলের পর্যায়ক্রমিক আবর্তন করুন, উপর থেকে পানি ছিটানো এড়িয়ে চলুন এবং কপার ব্যাকটেরিসাইড প্রয়োগ করুন।",
  "pepper bell healthy_symptoms": "গাঢ় সবুজ সতেজ পাতা এবং চকচকে, শক্ত মিষ্টি মরিচ সহ সুস্থ সবল গাছ।",
  "pepper bell healthy_management": "মাটি সমানভাবে আর্দ্র রাখুন, সুষম পুষ্টি দিয়ে সার দিন এবং গাছ সোজা রাখতে খুঁটি দিন।",
  "potato early blight_symptoms": "বয়স্ক পাতায় সমকেন্দ্রিক বলয় বিশিষ্ট গাঢ় দাগ (টার্গেট বোর্ড প্যাটার্ন) পড়ে। নিচের পাতাগুলো হলুদ হয়ে যায়।",
  "potato early blight_management": "গাছের শক্তি বজায় রাখুন, ফসল আবর্তন করুন, ফসলের অবশিষ্টাংশ ধ্বংস করুন এবং সুরক্ষামূলক ছত্রাকনাশক প্রয়োগ করুন।",
  "potato late blight_symptoms": "আর্দ্র আবহাওয়ায় পাতার নিচে সাদা ছাতা সহ দ্রুত বিস্তারকারী গাঢ় ও ভেজা দাগ দেখা যায়। আলু পচে যায়।",
  "potato late blight_management": "প্রত্যয়িত রোগমুক্ত বীজ রোপণ করুন, আগাছা বা বুনো আলু গাছ ধ্বংস করুন এবং প্রতিরোধমূলক ছত্রাকনাশক প্রয়োগ করুন।",
  "potato healthy_symptoms": "সবুজ ও ঘন পাতা এবং শক্তিশালী লতা। কোনো ক্ষত বা ছাতা (মোল্ড) নেই।",
  "potato healthy_management": "গাছের গোড়ায় মাটি তুলে দিন (হিলিং), গোড়ায় পানি দিন এবং শীতল ও আর্দ্র আবহাওয়ায় নিবিড়ভাবে পর্যবেক্ষণ করুন।",
  "raspberry healthy_symptoms": "সুস্থ সবুজ পাতা, খাড়া কান্ড এবং উজ্জ্বল ও মিষ্টি ফলের ছড়া।",
  "raspberry healthy_management": "পুরানো ফল দেওয়া কান্ড কেটে ফেলুন, আর্দ্রতা সংরক্ষণে মালচ করুন এবং সঠিক নিকাশী ব্যবস্থা নিশ্চিত করুন।",
  "soybean healthy_symptoms": "ঝোপঝাড় যুক্ত গাঢ় সবুজ পাতা, কোনো দাগ বা মরিচা রোগ ছাড়া চমৎকার শুঁটি (পড) উৎপাদন।",
  "soybean healthy_management": "সঠিক দূরত্ব বজায় রাখুন, ভুট্টা বা গমের সাথে পর্যায়ক্রমিক চাষ করুন এবং রাইজোবিয়াম দিয়ে বীজ শোধন করুন।",
  "squash powdery mildew_symptoms": "পাতা ও কান্ডে সাদা, গুঁড়ো ছত্রাকের দাগ ছড়িয়ে পড়ে, যার ফলে পাতা শুকিয়ে ও মরে যায়।",
  "squash powdery mildew_management": "পূর্ণ সূর্যালোক নিশ্চিত করুন, বাতাস চলাচলের জন্য ছাঁটাই করুন এবং পটাসিয়াম বাইকার্বোনেট বা neem oil স্প্রে করুন।",
  "strawberry leaf scorch_symptoms": "পাতায় বেগুনি রঙের দাগ যা পরে বড় হয়ে গাঢ় বাদামী হয়, ফলে পাতাগুলো পুড়ে যাওয়ার মতো দেখায়।",
  "strawberry leaf scorch_management": "প্রতিরোধী জাত রোপণ করুন, বেড সংস্কারের পর অতিরিক্ত পাতা কেটে ফেলুন এবং উপর থেকে পানি ছিটানো এড়িয়ে চলুন।",
  "strawberry healthy_symptoms": "উজ্জ্বল সবুজ পাতা, পরিষ্কার সাদা ফুল এবং পুষ্ট লাল স্ট্রবেরি ফল।",
  "strawberry healthy_management": "খড় দিয়ে মালচ করুন, দূরত্ব বজায় রাখতে বাড়তি রানার কেটে ফেলুন এবং নিয়মিত সেচ দিন।",
  "tomato bacterial spot_symptoms": "পাতা ও কান্ডে ছোট, গাঢ় এবং তৈলাক্ত দাগ। ফলের ওপর রুক্ষ ও খসখসে দাগ তৈরি হয়।",
  "tomato bacterial spot_management": "রোগমুক্ত বীজ ব্যবহার করুন, ফসল আবর্তন করুন, উপর থেকে পানি দেওয়া এড়িয়ে চলুন এবং কপার-ভিত্তিক স্প্রে প্রয়োগ করুন।",
  "tomato early blight_symptoms": "বয়স্ক পাতায় সমকেন্দ্রিক কালো দাগ পড়ে, যার ফলে পাতা হলুদ হয়ে ঝরে যায়। কান্ডের ক্ষত চারা গাছকে মেরে ফেলতে পারে।",
  "tomato early blight_management": "মাটিতে মালচ দিন, নিচের পাতা ছাঁটাই করুন, ফসল আবর্তন করুন এবং ক্লোরোথ্যালোনিল বা কপার ছত্রাকনাশক প্রয়োগ করুন।",
  "tomato late blight_symptoms": "আর্দ্র আবহাওয়াতে পাতার নিচে সাদাটে তুলতুলে ছাতা সহ দ্রুত বিস্তারকারী বড় গাঢ় বাদামী দাগ।",
  "tomato late blight_management": "আক্রান্ত গাছ অবিলম্বে তুলে ধ্বংস করুন, প্রতিরোধী জাত নির্বাচন করুন এবং প্রতিরোধমূলক কপার স্প্রে করুন।",
  "tomato leaf mold_symptoms": "পাতার উপরের পৃষ্ঠে হালকা সবুজ থেকে হলুদ দাগ এবং পাতার নিচের পৃষ্ঠে জলপাই-সবুজ মখমলের মতো ছাতা দেখা যায়।",
  "tomato leaf mold_management": "গ্রিনহাউসে আর্দ্রতা হ্রাস করুন, বাতাস চলাচল উন্নত করুন এবং প্রতিরোধী জাতের বীজ ব্যবহার করুন।",
  "tomato septoria leaf spot_symptoms": "নিচের পাতায় গাঢ় প্রান্ত এবং ধূসর কেন্দ্র বিশিষ্ট অসংখ্য ছোট, গোলাকার দাগ পড়ে, যা পাতা ঝরিয়ে দেয়।",
  "tomato septoria leaf spot_management": "উপর থেকে পানি দেওয়া এড়িয়ে চলুন, আক্রান্ত অবশিষ্টাংশ ধ্বংস করুন, মালচ করুন এবং ছত্রাকনাশক প্রয়োগ করুন।",
  "tomato spider mites two spotted spider mite_symptoms": "পাতায় সূক্ষ্ম হলুদ ছিট ছিট দাগ, এরপর পাতা ব্রোঞ্জ রঙ হয়ে শুকিয়ে যায় এবং পাতায় সূক্ষ্ম জালের মতো তৈরি হয়।",
  "tomato spider mites two spotted spider mite_management": "কীটনাশক সাবান স্প্রে করুন, উপকারী শিকারী মাকড়সা ছেড়ে দিন এবং গাছে পর্যাপ্ত পানি দিন।",
  "tomato target spot_symptoms": "পাতা ও ফলের ওপর সমকেন্দ্রিক বলয় বিশিষ্ট ছোট বাদামী দাগ (লক্ষ্যবস্তুর মতো), যা অকালে পাতা ঝরিয়ে দেয়।",
  "tomato target spot_management": "গাছগুলোর মধ্যে পর্যাপ্ত দূরত্ব রাখুন, নিচের পাতা ছাঁটাই করুন এবং সুরক্ষামূলক ছত্রাকনাশক প্রয়োগ করুন।",
  "tomato yellow leaf curl virus_symptoms": "গাছের বৃদ্ধি রুদ্ধ হওয়া, পাতাগুলো উপরের ও ভেতরের দিকে কুঁকড়ে যাওয়া এবং কিনারায় হলুদ হওয়া। ফলন অনেক কমে যায়।",
  "tomato yellow leaf curl virus_management": "রো কভার, হলুদ আঠালো ফাঁদ বা কীটনাশক দিয়ে সাদা মাছি পোকা দমন করুন এবং প্রতিরোধী জাত রোপণ করুন।",
  "tomato mosaic virus_symptoms": "পাতায় হালকা ও গাঢ় সবুজ রঙের মোজাইক নকশা, পাতা বিকৃতি (shoestringing) এবং ফলের অসম পাকন।",
  "tomato mosaic virus_management": "যন্ত্রপাতি জীবাণুমুক্ত করুন, সাবান দিয়ে হাত ধুয়ে নিন, প্রতিরোধী জাত রোপণ করুন এবং আক্রান্ত গাছ ধ্বংস করুন।",
  "tomato healthy_symptoms": "দাগ, কোঁকড়ানো বা ছাতামুক্ত শক্তিশালী ডালপালা, গাঢ় সবুজ পাতা এবং লাল টমেটো ফল।",
  "tomato healthy_management": "অপ্রয়োজনীয় কন্দ (সাকার) ছাঁটাই করুন, গাছকে খুঁটি দিয়ে ডেকে দিন, গোড়ায় গভীর সেচ দিন এবং নিয়মিত সার দিন।",
  "background_symptoms": "ছবিতে কোনো স্পষ্ট পাতার অংশ দেখা যাচ্ছে না অথবা ছবিটি ফোকাসে নেই।",
  "background_management": "দয়া করে ক্যামেরাটি আরও কাছে ধরুন এবং আক্রান্ত পাতার ওপর ফোকাস করে ছবি তুলুন।",
  "turn_on_internet": "ইন্টারনেট চালু করুন",
  "exit_app": "অ্যাপ থেকে প্রস্থান",
  "exit_confirmation": "আপনি কি নিশ্চিত যে আপনি অ্যাপ থেকে বের হতে চান?",
  "cancel": "বাতিল",
  "exit": "প্রস্থান"
};
