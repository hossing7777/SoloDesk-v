class Project {
  const Project({
    this.id,
    this.clientId,
    required this.name,
    this.rate = 0,
    this.done = false,
    this.createdAt = 0,
  });

  factory Project.fromJson(Map<String, Object?> j) => Project(
        id: j['id'] as int?,
        clientId: j['client_id'] as int?,
        name: j['name'] as String,
        rate: (j['rate'] as num?)?.toDouble() ?? 0,
        done: ((j['done'] as int?) ?? 0) == 1,
        createdAt: (j['created_at'] as int?) ?? 0,
      );

  final int? id;
  final int? clientId;
  final String name;
  final double rate;
  final bool done;
  final int createdAt;

  Map<String, Object?> toJson() => {
        if (id != null) 'id': id,
        'client_id': clientId,
        'name': name,
        'rate': rate,
        'done': done ? 1 : 0,
        'created_at': createdAt,
      };
}
