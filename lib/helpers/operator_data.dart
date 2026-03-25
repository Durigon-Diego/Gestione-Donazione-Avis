/// Represents the full profile data of an operator.
class OperatorData {
  final String _id;
  final String? _authUserId;
  final String _firstName;
  final String _lastName;
  final String? _nickname;
  final bool _isActive;
  final bool _isAdmin;

  final DateTime _createdAt;
  final String? _createdBy;
  final String? _createdByFirstName;
  final String? _createdByLastName;
  final String? _createdByNickname;

  final DateTime _updatedAt;
  final String? _updatedBy;
  final String? _updatedByFirstName;
  final String? _updatedByLastName;
  final String? _updatedByNickname;

  final DateTime? _deletedAt;
  final String? _deletedBy;
  final String? _deletedByFirstName;
  final String? _deletedByLastName;
  final String? _deletedByNickname;

  /// Returns the formatted full name of this operator.
  String get name => formatName(_firstName, _lastName, _nickname);

  String get id => _id;
  String? get authUserId => _authUserId;
  String get firstName => _firstName;
  String get lastName => _lastName;
  String? get nickname => _nickname;
  bool get isActive => _isActive;
  bool get isAdmin => _isAdmin;
  bool get isDeleted => _authUserId == null || _authUserId.isEmpty;

  DateTime get createdAt => _createdAt;
  String? get createdBy => _createdBy;
  String? get createdByFirstName => _createdByFirstName;
  String? get createdByLastName => _createdByLastName;
  String? get createdByNickname => _createdByNickname;
  String? get createdByName => (_createdBy == null)
      ? null
      : formatName(
          _createdByFirstName!, _createdByLastName!, _createdByNickname);

  DateTime get updatedAt => _updatedAt;
  String? get updatedBy => _updatedBy;
  String? get updatedByFirstName => _updatedByFirstName;
  String? get updatedByLastName => _updatedByLastName;
  String? get updatedByNickname => _updatedByNickname;
  String? get updatedByName => (_updatedBy == null)
      ? null
      : formatName(
          _updatedByFirstName!, _updatedByLastName!, _updatedByNickname);

  DateTime? get deletedAt => _deletedAt;
  String? get deletedBy => _deletedBy;
  String? get deletedByFirstName => _deletedByFirstName;
  String? get deletedByLastName => _deletedByLastName;
  String? get deletedByNickname => _deletedByNickname;
  String? get deletedByName => (_deletedBy == null)
      ? null
      : formatName(
          _deletedByFirstName!, _deletedByLastName!, _deletedByNickname);

  /// Constructs a full OperatorData object from a Supabase row.
  OperatorData({
    required String id,
    String? authUserId,
    required String firstName,
    required String lastName,
    String? nickname,
    required bool isActive,
    required bool isAdmin,
    DateTime? createdAt,
    String? createdBy,
    String? createdByFirstName,
    String? createdByLastName,
    String? createdByNickname,
    DateTime? updatedAt,
    String? updatedBy,
    String? updatedByFirstName,
    String? updatedByLastName,
    String? updatedByNickname,
    DateTime? deletedAt,
    String? deletedBy,
    String? deletedByFirstName,
    String? deletedByLastName,
    String? deletedByNickname,
  })  : _id = id,
        _authUserId = authUserId,
        _firstName = firstName,
        _lastName = lastName,
        _nickname = nickname,
        _isActive = isActive,
        _isAdmin = isAdmin,
        _createdAt = createdAt ?? DateTime.now(),
        _createdBy = createdBy,
        _createdByFirstName = createdByFirstName,
        _createdByLastName = createdByLastName,
        _createdByNickname = createdByNickname,
        _updatedAt = updatedAt ?? DateTime.now(),
        _updatedBy = updatedBy,
        _updatedByFirstName = updatedByFirstName,
        _updatedByLastName = updatedByLastName,
        _updatedByNickname = updatedByNickname,
        _deletedAt = deletedAt,
        _deletedBy = deletedBy,
        _deletedByFirstName = deletedByFirstName,
        _deletedByLastName = deletedByLastName,
        _deletedByNickname = deletedByNickname;

  /// Builds an instance of OperatorData from a Supabase DB row.
  factory OperatorData.fromMap(Map<String, dynamic> map) {
    return OperatorData(
      id: map['id'] as String,
      authUserId: map['auth_user_id'] as String?,
      firstName: map['first_name'] as String,
      lastName: map['last_name'] as String,
      nickname: map['nickname'] as String?,
      isActive: map['active'] as bool,
      isAdmin: map['is_admin'] as bool,
      createdAt: DateTime.parse(map['created_at'] as String),
      createdBy: map['created_by'] as String?,
      createdByFirstName: map['created_by_first_name'] as String?,
      createdByLastName: map['created_by_last_name'] as String?,
      createdByNickname: map['created_by_nickname'] as String?,
      updatedAt: DateTime.parse(map['updated_at'] as String),
      updatedBy: map['updated_by'] as String?,
      updatedByFirstName: map['updated_by_first_name'] as String?,
      updatedByLastName: map['updated_by_last_name'] as String?,
      updatedByNickname: map['updated_by_nickname'] as String?,
      deletedAt:
          map['deleted_at'] != null ? DateTime.parse(map['deleted_at']) : null,
      deletedBy: map['deleted_by'] as String?,
      deletedByFirstName: map['deleted_by_first_name'] as String?,
      deletedByLastName: map['deleted_by_last_name'] as String?,
      deletedByNickname: map['deleted_by_nickname'] as String?,
    );
  }

  /// Static helper to format full names with optional nickname.
  static String formatName(String first, String last, String? nickname) {
    if (nickname != null && nickname.trim().isNotEmpty) {
      return '$first $last ($nickname)';
    }
    return '$first $last';
  }
}
