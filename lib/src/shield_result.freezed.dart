// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'shield_result.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ShieldResult {
  bool get passed;
  bool get isJailbroken;
  bool get isRooted;
  bool get isFridaDetected;
  List<ShieldThreat> get threats;

  /// Create a copy of ShieldResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $ShieldResultCopyWith<ShieldResult> get copyWith =>
      _$ShieldResultCopyWithImpl<ShieldResult>(
          this as ShieldResult, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is ShieldResult &&
            (identical(other.passed, passed) || other.passed == passed) &&
            (identical(other.isJailbroken, isJailbroken) ||
                other.isJailbroken == isJailbroken) &&
            (identical(other.isRooted, isRooted) ||
                other.isRooted == isRooted) &&
            (identical(other.isFridaDetected, isFridaDetected) ||
                other.isFridaDetected == isFridaDetected) &&
            const DeepCollectionEquality().equals(other.threats, threats));
  }

  @override
  int get hashCode => Object.hash(runtimeType, passed, isJailbroken, isRooted,
      isFridaDetected, const DeepCollectionEquality().hash(threats));

  @override
  String toString() {
    return 'ShieldResult(passed: $passed, isJailbroken: $isJailbroken, isRooted: $isRooted, isFridaDetected: $isFridaDetected, threats: $threats)';
  }
}

/// @nodoc
abstract mixin class $ShieldResultCopyWith<$Res> {
  factory $ShieldResultCopyWith(
          ShieldResult value, $Res Function(ShieldResult) _then) =
      _$ShieldResultCopyWithImpl;
  @useResult
  $Res call(
      {bool passed,
      bool isJailbroken,
      bool isRooted,
      bool isFridaDetected,
      List<ShieldThreat> threats});
}

/// @nodoc
class _$ShieldResultCopyWithImpl<$Res> implements $ShieldResultCopyWith<$Res> {
  _$ShieldResultCopyWithImpl(this._self, this._then);

  final ShieldResult _self;
  final $Res Function(ShieldResult) _then;

  /// Create a copy of ShieldResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? passed = null,
    Object? isJailbroken = null,
    Object? isRooted = null,
    Object? isFridaDetected = null,
    Object? threats = null,
  }) {
    return _then(_self.copyWith(
      passed: null == passed
          ? _self.passed
          : passed // ignore: cast_nullable_to_non_nullable
              as bool,
      isJailbroken: null == isJailbroken
          ? _self.isJailbroken
          : isJailbroken // ignore: cast_nullable_to_non_nullable
              as bool,
      isRooted: null == isRooted
          ? _self.isRooted
          : isRooted // ignore: cast_nullable_to_non_nullable
              as bool,
      isFridaDetected: null == isFridaDetected
          ? _self.isFridaDetected
          : isFridaDetected // ignore: cast_nullable_to_non_nullable
              as bool,
      threats: null == threats
          ? _self.threats
          : threats // ignore: cast_nullable_to_non_nullable
              as List<ShieldThreat>,
    ));
  }
}

/// Adds pattern-matching-related methods to [ShieldResult].
extension ShieldResultPatterns on ShieldResult {
  /// A variant of `map` that fallback to returning `orElse`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_ShieldResult value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _ShieldResult() when $default != null:
        return $default(_that);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// Callbacks receives the raw object, upcasted.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case final Subclass2 value:
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_ShieldResult value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ShieldResult():
        return $default(_that);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `map` that fallback to returning `null`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_ShieldResult value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ShieldResult() when $default != null:
        return $default(_that);
      case _:
        return null;
    }
  }

  /// A variant of `when` that fallback to an `orElse` callback.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(bool passed, bool isJailbroken, bool isRooted,
            bool isFridaDetected, List<ShieldThreat> threats)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _ShieldResult() when $default != null:
        return $default(_that.passed, _that.isJailbroken, _that.isRooted,
            _that.isFridaDetected, _that.threats);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// As opposed to `map`, this offers destructuring.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case Subclass2(:final field2):
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(bool passed, bool isJailbroken, bool isRooted,
            bool isFridaDetected, List<ShieldThreat> threats)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ShieldResult():
        return $default(_that.passed, _that.isJailbroken, _that.isRooted,
            _that.isFridaDetected, _that.threats);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `when` that fallback to returning `null`
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(bool passed, bool isJailbroken, bool isRooted,
            bool isFridaDetected, List<ShieldThreat> threats)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ShieldResult() when $default != null:
        return $default(_that.passed, _that.isJailbroken, _that.isRooted,
            _that.isFridaDetected, _that.threats);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _ShieldResult implements ShieldResult {
  const _ShieldResult(
      {required this.passed,
      required this.isJailbroken,
      required this.isRooted,
      required this.isFridaDetected,
      required final List<ShieldThreat> threats})
      : _threats = threats;

  @override
  final bool passed;
  @override
  final bool isJailbroken;
  @override
  final bool isRooted;
  @override
  final bool isFridaDetected;
  final List<ShieldThreat> _threats;
  @override
  List<ShieldThreat> get threats {
    if (_threats is EqualUnmodifiableListView) return _threats;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_threats);
  }

  /// Create a copy of ShieldResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$ShieldResultCopyWith<_ShieldResult> get copyWith =>
      __$ShieldResultCopyWithImpl<_ShieldResult>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _ShieldResult &&
            (identical(other.passed, passed) || other.passed == passed) &&
            (identical(other.isJailbroken, isJailbroken) ||
                other.isJailbroken == isJailbroken) &&
            (identical(other.isRooted, isRooted) ||
                other.isRooted == isRooted) &&
            (identical(other.isFridaDetected, isFridaDetected) ||
                other.isFridaDetected == isFridaDetected) &&
            const DeepCollectionEquality().equals(other._threats, _threats));
  }

  @override
  int get hashCode => Object.hash(runtimeType, passed, isJailbroken, isRooted,
      isFridaDetected, const DeepCollectionEquality().hash(_threats));

  @override
  String toString() {
    return 'ShieldResult(passed: $passed, isJailbroken: $isJailbroken, isRooted: $isRooted, isFridaDetected: $isFridaDetected, threats: $threats)';
  }
}

/// @nodoc
abstract mixin class _$ShieldResultCopyWith<$Res>
    implements $ShieldResultCopyWith<$Res> {
  factory _$ShieldResultCopyWith(
          _ShieldResult value, $Res Function(_ShieldResult) _then) =
      __$ShieldResultCopyWithImpl;
  @override
  @useResult
  $Res call(
      {bool passed,
      bool isJailbroken,
      bool isRooted,
      bool isFridaDetected,
      List<ShieldThreat> threats});
}

/// @nodoc
class __$ShieldResultCopyWithImpl<$Res>
    implements _$ShieldResultCopyWith<$Res> {
  __$ShieldResultCopyWithImpl(this._self, this._then);

  final _ShieldResult _self;
  final $Res Function(_ShieldResult) _then;

  /// Create a copy of ShieldResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? passed = null,
    Object? isJailbroken = null,
    Object? isRooted = null,
    Object? isFridaDetected = null,
    Object? threats = null,
  }) {
    return _then(_ShieldResult(
      passed: null == passed
          ? _self.passed
          : passed // ignore: cast_nullable_to_non_nullable
              as bool,
      isJailbroken: null == isJailbroken
          ? _self.isJailbroken
          : isJailbroken // ignore: cast_nullable_to_non_nullable
              as bool,
      isRooted: null == isRooted
          ? _self.isRooted
          : isRooted // ignore: cast_nullable_to_non_nullable
              as bool,
      isFridaDetected: null == isFridaDetected
          ? _self.isFridaDetected
          : isFridaDetected // ignore: cast_nullable_to_non_nullable
              as bool,
      threats: null == threats
          ? _self._threats
          : threats // ignore: cast_nullable_to_non_nullable
              as List<ShieldThreat>,
    ));
  }
}

// dart format on
