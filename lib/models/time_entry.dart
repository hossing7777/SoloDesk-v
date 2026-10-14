class TimeEntry {
  const TimeEntry({
    this.id,
    required this.projectId,
    required this.startedAt,
    required this.endedAt,
    this.note = '',
  });

  factory TimeEntry.fromJson(Map<String, Object?> j) => TimeEntry(
        id: j['id'] as int?,
        projectId: j['project_id'] as int,
        startedAt: j['started_at'] as int,
        endedAt: j['ended_at'] as int,
        note: (j['note'] as String?) ?? '',
      );

  final int? id;
  final int projectId;
  final int startedAt;
  final int endedAt;
  final String note;

  Duration get duration => Duration(milliseconds: endedAt - startedAt);

  Map<String, Object?> toJson() => {
        if (id != null) 'id': id,
        'project_id': projectId,
        'started_at': startedAt,
        'ended_at': endedAt,
        'note': note,
      };
}
