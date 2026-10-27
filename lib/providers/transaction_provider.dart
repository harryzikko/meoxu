import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/transaction_item.dart';
import '../core/database/app_database.dart';

class TransactionState {
  final List<TransactionItem> allTransactions;
  final TransactionItem? lastDeletedItem;
  final bool isLoading;

  const TransactionState({
    this.allTransactions = const [],
    this.lastDeletedItem,
    this.isLoading = false,
  });

  TransactionState copyWith({
    List<TransactionItem>? allTransactions,
    TransactionItem? lastDeletedItem,
    bool? isLoading,
  }) {
    return TransactionState(
      allTransactions: allTransactions ?? this.allTransactions,
      lastDeletedItem: lastDeletedItem ?? this.lastDeletedItem,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class TransactionNotifier extends StateNotifier<TransactionState> {
  TransactionNotifier() : super(const TransactionState()) {
    loadTransactions();
  }

  Future<void> loadTransactions() async {
    state = state.copyWith(isLoading: true);
    try {
      final items = await AppDatabase.instance.getAllTransactions();
      state = state.copyWith(allTransactions: items, isLoading: false);
    } catch (_) {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> addTransaction(
    TransactionItem item, {
    String? originalKeyword,
  }) async {
    await AppDatabase.instance.insertTransaction(item);
    state = state.copyWith(allTransactions: [item, ...state.allTransactions]);

    // Learn keyword if provided
    if (originalKeyword != null && originalKeyword.isNotEmpty) {
      await AppDatabase.instance.saveKeywordRule(
        originalKeyword,
        item.categoryId,
      );
    }
  }

  Future<void> updateTransaction(TransactionItem item) async {
    await AppDatabase.instance.updateTransaction(item);
    state = state.copyWith(
      allTransactions: state.allTransactions
          .map((tx) => tx.id == item.id ? item : tx)
          .toList(),
    );
  }

  Future<void> attachEmotion(String transactionId, String emotion) async {
    final txIndex = state.allTransactions.indexWhere(
      (tx) => tx.id == transactionId,
    );
    if (txIndex != -1) {
      final updated = state.allTransactions[txIndex].copyWith(emotion: emotion);
      await updateTransaction(updated);
    }
  }

  Future<void> deleteTransaction(String id) async {
    final itemToDelete = state.allTransactions.firstWhere((tx) => tx.id == id);
    await AppDatabase.instance.deleteTransaction(id);
    state = state.copyWith(
      allTransactions: state.allTransactions
          .where((tx) => tx.id != id)
          .toList(),
      lastDeletedItem: itemToDelete,
    );
  }

  Future<void> undoDelete() async {
    if (state.lastDeletedItem != null) {
      await addTransaction(state.lastDeletedItem!);
      state = state.copyWith(lastDeletedItem: null);
    }
  }
}

final transactionProvider =
    StateNotifierProvider<TransactionNotifier, TransactionState>((ref) {
      return TransactionNotifier();
    });
