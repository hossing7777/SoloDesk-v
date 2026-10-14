class Client {
  const Client({
    this.id,
    required this.name,
    this.email = '',
    this.phone = '',
    this.address = '',
    this.notes = '',
    this.createdAt = 0,
  });

  factory Client.fromJson(Map<String, Object?> j) => Client(
        id: j['id'] as int?,
        name: j['name'] as String,
        email: (j['email'] as String?) ?? '',
        phone: (j['phone'] as String?) ?? '',
        address: (j['address'] as String?) ?? '',
        notes: (j['notes'] as String?) ?? '',
        createdAt: (j['created_at'] as int?) ?? 0,
      );

  final int? id;
  final String name;
  final String email;
  final String phone;
  final String address;
  final String notes;
  final int createdAt;

  Map<String, Object?> toJson() => {
        if (id != null) 'id': id,
        'name': name,
        'email': email,
        'phone': phone,
        'address': address,
        'notes': notes,
        'created_at': createdAt,
      };
}
