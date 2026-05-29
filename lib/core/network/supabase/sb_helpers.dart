import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../utils/date_time_extensions.dart';
import 'sb_tables.dart';

typedef Json = Map<String, dynamic>;

class SbHelpers {
  SbHelpers(this._supabase, SBTables sbTable) : _table = sbTable.tableName;

  final String _table;
  final SupabaseClient _supabase;

  SupabaseQueryBuilder _query() => _supabase.from(_table);

  PostgrestFilterBuilder<List<Map<String, dynamic>>> select({required String columns}) {
    return _query().select(columns);
  }

  Future<Json> insertWithReturn(Object values, {required String columns}) async {
    final PostgrestMap response = await _query().insert(values).select(columns).limit(1).single();
    return response;
  }

  PostgrestFilterBuilder<dynamic> insert(Object values) {
    return _query().insert(values);
  }

  PostgrestFilterBuilder<dynamic> update({
    required Json data,
    required Map<String, Object> where,
    bool addUpdatedAt = true,
  }) {
    assert(where.isNotEmpty, 'Update must have where!');

    if (addUpdatedAt) {
      data.addAll({'updated_at': DateTime.now().toServerFormat()});
    }

    PostgrestFilterBuilder<dynamic> q = _query().update(data);

    for (final MapEntry<String, Object> eq in where.entries) {
      q = q.eq(eq.key, eq.value);
    }

    return q;
  }

  Future<void> upsert(
    Map<String, dynamic> data, {
    required String onConflict,
    bool ignoreDuplicates = false,
    bool defaultToNull = true,
    bool addUpdatedAt = true,
  }) {
    if (addUpdatedAt) {
      data.addAll({'updated_at': DateTime.now().toServerFormat()});
    }

    return _query().upsert(
      data,
      onConflict: onConflict,
      ignoreDuplicates: ignoreDuplicates,
      defaultToNull: defaultToNull,
    );
  }

  Future<void> delete(Map<String, Object> where) async {
    assert(where.isNotEmpty, 'Delete must have where!');

    PostgrestFilterBuilder<dynamic> q = _query().delete();

    for (final MapEntry<String, Object> eq in where.entries) {
      q = q.eq(eq.key, eq.value);
    }

    await q;
  }

  Future<T?> maybeSingle<T>(
    T Function(Json) converter, {
    String columns = '*',
    Map<String, Object>? where,
  }) async {
    PostgrestFilterBuilder<List<Map<String, dynamic>>> q = select(columns: columns);

    if (where != null) {
      for (final MapEntry<String, Object> eq in where.entries) {
        q = q.eq(eq.key, eq.value);
      }
    }

    return await q.limit(1).maybeSingle().withConverter((d) => d == null ? null : converter(d));
  }

  Future<T> single<T>(
    T Function(Json) converter, {
    required String columns,
    Map<String, Object>? where,
  }) {
    PostgrestFilterBuilder<List<Map<String, dynamic>>> q = select(columns: columns);

    if (where != null) {
      for (final MapEntry<String, Object> eq in where.entries) {
        q = q.eq(eq.key, eq.value);
      }
    }

    return q.limit(1).single().withConverter(converter);
  }

  Stream<List<T>> stream<T>(List<String> pk, T Function(Json) converter) {
    assert(pk.isNotEmpty, 'Primary key is mandatory');

    return _query().stream(primaryKey: pk).map((data) => data.map(converter).toList());
  }

  Stream<List<T>> streamOrder<T>(
    T Function(Json) converter, {
    required List<String> pk,
    Map<String, Object>? where,
    String? orderBy,
    bool ascending = false,
  }) {
    assert(pk.isNotEmpty, 'Primary key is mandatory');

    Stream<List<Map<String, dynamic>>> sourceStream;

    if (orderBy != null) {
      sourceStream = _query().stream(primaryKey: pk).order(orderBy, ascending: ascending);
    } else {
      sourceStream = _query().stream(primaryKey: pk);
    }

    return sourceStream.map((data) {
      if (where == null || where.isEmpty) {
        return data.map(converter).toList();
      }

      final Iterable<Map<String, dynamic>> filteredList = data.where((row) {
        for (final MapEntry<String, Object> entry in where.entries) {
          if (row[entry.key] != entry.value) {
            return false;
          }
        }
        return true;
      });

      return filteredList.map(converter).toList();
    });
  }

  Future<Iterable<T>> array<T>(
    T Function(Json) converter, {
    required String columns,
    Map<String, Object>? where,
  }) {
    PostgrestFilterBuilder<List<Map<String, dynamic>>> q = select(columns: columns);

    if (where != null) {
      for (final MapEntry<String, Object> eq in where.entries) {
        q = q.eq(eq.key, eq.value);
      }
    }

    return q.withConverter((d) => d.map(converter));
  }
}
