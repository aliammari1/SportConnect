import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sport_connect/features/legal/views/legal_screen.dart';

part 'legal_view_model.g.dart';

class LegalScreenUiState {
  const LegalScreenUiState({this.isLoading = true, this.hasError = false});

  final bool isLoading;
  final bool hasError;

  LegalScreenUiState copyWith({bool? isLoading, bool? hasError}) {
    return LegalScreenUiState(
      isLoading: isLoading ?? this.isLoading,
      hasError: hasError ?? this.hasError,
    );
  }
}

@riverpod
class LegalScreenUiViewModel extends _$LegalScreenUiViewModel {
  @override
  LegalScreenUiState build(LegalDocumentType arg) => const LegalScreenUiState();

  void setLoading(bool value) {
    if (state.isLoading == value) return;
    state = state.copyWith(isLoading: value);
  }

  void setError() {
    state = state.copyWith(isLoading: false, hasError: true);
  }

  void retry() {
    state = const LegalScreenUiState();
  }
}
