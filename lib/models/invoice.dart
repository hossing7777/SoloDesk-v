class Invoice {
  const Invoice({
    this.id,
    required this.number,
    this.clientId,
    required this.issueDate,
    required this.dueDate,
    this.status = draft,
    this.tax = 0,
    this.notes = '',
    this.recurring = false,
    this.template = 'classic',
    this.total = 0,
  });

  factory Invoice.fromJson(Map<String, Object?> j) => Invoice(
        id: j['id'] as int?,
        number: j['number'] as String,
        clientId: j['client_id'] as int?,
        issueDate: j['issue_date'] as int,
        dueDate: j['due_date'] as int,
        status: (j['status'] as int?) ?? draft,
        tax: (j['tax'] as num?)?.toDouble() ?? 0,
        notes: (j['notes'] as String?) ?? '',
        recurring: ((j['recurring'] as int?) ?? 0) == 1,
        template: (j['template'] as String?) ?? 'classic',
        total: (j['total'] as num?)?.toDouble() ?? 0,
      );

  static const int draft = 0;
  static const int sent = 1;
  static const int paid = 2;

  final int? id;
  final String number;
  final int? clientId;
  final int issueDate;
  final int dueDate;
  final int status;
  final double tax;
  final String notes;
  final bool recurring;
  final String template;
  final double total;

  bool get isOverdue => status == sent && dueDate < DateTime.now().millisecondsSinceEpoch;

  Invoice copyWith({int? id, int? status}) => Invoice(
        id: id ?? this.id,
        number: number,
        clientId: clientId,
        issueDate: issueDate,
        dueDate: dueDate,
        status: status ?? this.status,
        tax: tax,
        notes: notes,
        recurring: recurring,
        template: template,
        total: total,
      );

  Map<String, Object?> toJson() => {
        if (id != null) 'id': id,
        'number': number,
        'client_id': clientId,
        'issue_date': issueDate,
        'due_date': dueDate,
        'status': status,
        'tax': tax,
        'notes': notes,
        'recurring': recurring ? 1 : 0,
        'template': template,
        'total': total,
      };
}

class InvoiceItem {
  const InvoiceItem({
    this.id,
    this.invoiceId = 0,
    required this.description,
    required this.qty,
    required this.price,
  });

  factory InvoiceItem.fromJson(Map<String, Object?> j) => InvoiceItem(
        id: j['id'] as int?,
        invoiceId: (j['invoice_id'] as int?) ?? 0,
        description: (j['description'] as String?) ?? '',
        qty: (j['qty'] as num?)?.toDouble() ?? 0,
        price: (j['price'] as num?)?.toDouble() ?? 0,
      );

  final int? id;
  final int invoiceId;
  final String description;
  final double qty;
  final double price;

  double get amount => qty * price;

  /// Item ids are never written: items are re-inserted on every save.
  Map<String, Object?> toJson({int? forInvoice}) => {
        'invoice_id': forInvoice ?? invoiceId,
        'description': description,
        'qty': qty,
        'price': price,
      };
}
