import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/errors/failures.dart';
import '../data/settings_repository.dart';

class SettingsState {
  final bool isLoading;
  final bool isSubmitting;
  final String storeName;
  final String address;
  final String phone;
  final String receiptHeader;
  final String receiptFooter;
  final double taxRate;
  final String currencySymbol;
  final ThemeMode themeMode;
  final bool autoPrintReceipt;
  final Failure? failure;

  const SettingsState({
    this.isLoading = false,
    this.isSubmitting = false,
    this.storeName = 'My POS Store',
    this.address = 'Jl. Utama No. 45, Jakarta',
    this.phone = '021-5550199',
    this.receiptHeader = 'Welcome to My POS Store',
    this.receiptFooter = 'Thank you for shopping with us!',
    this.taxRate = 10.0,
    this.currencySymbol = 'Rp',
    this.themeMode = ThemeMode.system,
    this.autoPrintReceipt = false,
    this.failure,
  });

  SettingsState copyWith({
    bool? isLoading,
    bool? isSubmitting,
    String? storeName,
    String? address,
    String? phone,
    String? receiptHeader,
    String? receiptFooter,
    double? taxRate,
    String? currencySymbol,
    ThemeMode? themeMode,
    bool? autoPrintReceipt,
    Failure? failure,
    bool clearFailure = false,
  }) {
    return SettingsState(
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      storeName: storeName ?? this.storeName,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      receiptHeader: receiptHeader ?? this.receiptHeader,
      receiptFooter: receiptFooter ?? this.receiptFooter,
      taxRate: taxRate ?? this.taxRate,
      currencySymbol: currencySymbol ?? this.currencySymbol,
      themeMode: themeMode ?? this.themeMode,
      autoPrintReceipt: autoPrintReceipt ?? this.autoPrintReceipt,
      failure: clearFailure ? null : (failure ?? this.failure),
    );
  }
}

final settingsControllerProvider =
    StateNotifierProvider<SettingsController, SettingsState>((ref) {
  final repository = ref.watch(settingsRepositoryProvider);
  return SettingsController(repository);
});

class SettingsController extends StateNotifier<SettingsState> {
  final SettingsRepository repository;

  SettingsController(this.repository) : super(const SettingsState()) {
    fetchSettings();
  }

  Future<void> fetchSettings() async {
    state = state.copyWith(isLoading: true, clearFailure: true);
    try {
      final data = await repository.getStoreSettings();
      state = state.copyWith(
        isLoading: false,
        storeName: data['store_name']?.toString() ?? 'My POS Store',
        address: data['address']?.toString() ?? '',
        phone: data['phone']?.toString() ?? '',
        receiptHeader: data['receipt_header']?.toString() ?? '',
        receiptFooter: data['receipt_footer']?.toString() ?? '',
        taxRate: double.tryParse(data['tax_rate']?.toString() ?? '10.0') ?? 10.0,
        currencySymbol: data['currency_symbol']?.toString() ?? 'Rp',
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        failure: ServerFailure(message: e.toString()),
      );
    }
  }

  void setThemeMode(ThemeMode mode) {
    state = state.copyWith(themeMode: mode);
  }

  void setAutoPrintReceipt(bool enable) {
    state = state.copyWith(autoPrintReceipt: enable);
  }

  Future<bool> saveStoreSettings(Map<String, dynamic> payload) async {
    state = state.copyWith(isSubmitting: true, clearFailure: true);
    try {
      final success = await repository.updateStoreSettings(payload);
      if (success) {
        state = state.copyWith(
          isSubmitting: false,
          storeName: payload['store_name']?.toString() ?? state.storeName,
          address: payload['address']?.toString() ?? state.address,
          phone: payload['phone']?.toString() ?? state.phone,
          receiptHeader: payload['receipt_header']?.toString() ?? state.receiptHeader,
          receiptFooter: payload['receipt_footer']?.toString() ?? state.receiptFooter,
          taxRate: double.tryParse(payload['tax_rate']?.toString() ?? '${state.taxRate}') ?? state.taxRate,
        );
      }
      state = state.copyWith(isSubmitting: false);
      return success;
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        failure: ServerFailure(message: e.toString()),
      );
      return false;
    }
  }
}
