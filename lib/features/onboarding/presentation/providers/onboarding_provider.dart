import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';


enum OnboardingStatus { initial, inProgress, completed }

class OnboardingState {
  final OnboardingStatus status;
  final int currentPage;

  const OnboardingState({
    this.status = OnboardingStatus.initial,
    this.currentPage = 0,
  });

  OnboardingState copyWith({OnboardingStatus? status, int? currentPage}) {
    return OnboardingState(
      status: status ?? this.status,
      currentPage: currentPage ?? this.currentPage,
    );
  }
}

class OnboardingNotifier extends StateNotifier<OnboardingState> {
  OnboardingNotifier() : super(const OnboardingState());

  void start() {
    state = state.copyWith(status: OnboardingStatus.inProgress);
  }

  void goToPage(int page) {
    state = state.copyWith(currentPage: page);
  }

  void nextPage(int totalPages) {
    if (state.currentPage < totalPages - 1) {
      state = state.copyWith(currentPage: state.currentPage + 1);
    }
  }

  Future<void> skip() async {
    state = state.copyWith(status: OnboardingStatus.completed);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('onboarding_completed', true);
    } catch (_) {}
  }

  Future<void> complete() async {
    state = state.copyWith(status: OnboardingStatus.completed);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('onboarding_completed', true);
    } catch (_) {}
  }
}

final onboardingProvider =
    StateNotifierProvider<OnboardingNotifier, OnboardingState>((ref) {
      return OnboardingNotifier();
    });
