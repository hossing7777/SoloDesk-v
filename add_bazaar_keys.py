import json, os
L = ['en','fa','ar','es','fr','de','pt','ru','hi','zh']
T = {
'paywallTitle': ['SoloDesk Pro','نسخه حرفه‌ای SoloDesk','SoloDesk Pro','SoloDesk Pro','SoloDesk Pro','SoloDesk Pro','SoloDesk Pro','SoloDesk Pro','SoloDesk Pro','SoloDesk Pro'],
'paywallSubtitle': ['Unlimited access to every feature','دسترسی نامحدود به همه امکانات','وصول غير محدود إلى كل الميزات','Acceso ilimitado a todas las funciones','Accès illimité à toutes les fonctionnalités','Unbegrenzter Zugriff auf alle Funktionen','Acesso ilimitado a todos os recursos','Безлимитный доступ ко всем функциям','सभी सुविधाओं तक असीमित पहुंच','无限使用全部功能'],
'paywallFeature1': ['Unlimited clients and invoices','مشتریان و فاکتورهای نامحدود','عملاء وفواتير غير محدودة','Clientes y facturas ilimitados','Clients et factures illimités','Unbegrenzte Kunden und Rechnungen','Clientes e faturas ilimitados','Неограниченное число клиентов и счетов','असीमित क्लाइंट और इनवॉइस','客户和发票无限制'],
'paywallFeature2': ['All invoice templates and PDF export','همه قالب‌های فاکتور و خروجی PDF','جميع قوالب الفواتير وتصدير PDF','Todas las plantillas y exportación a PDF','Tous les modèles de facture et export PDF','Alle Rechnungsvorlagen und PDF-Export','Todos os modelos de fatura e exportação em PDF','Все шаблоны счетов и экспорт в PDF','सभी इनवॉइस टेम्पलेट और PDF निर्यात','全部发票模板及 PDF 导出'],
'paywallFeature3': ['Backup and restore','پشتیبان‌گیری و بازیابی','النسخ الاحتياطي والاستعادة','Copia de seguridad y restauración','Sauvegarde et restauration','Backup und Wiederherstellung','Backup e restauração','Резервное копирование и восстановление','बैकअप और रिस्टोर','备份与恢复'],
'buyProButton': ['Buy Pro','خرید نسخه حرفه‌ای','شراء النسخة الاحترافية','Comprar Pro','Acheter Pro','Pro kaufen','Comprar Pro','Купить Pro','प्रो खरीदें','购买专业版'],
'restorePurchase': ['Restore purchase','بازیابی خرید','استعادة الشراء','Restaurar compra','Restaurer l’achat','Kauf wiederherstellen','Restaurar compra','Восстановить покупку','खरीदारी रिस्टोर करें','恢复购买'],
'trialLimitReached': ['You’ve reached the free plan limit','به محدودیت نسخه رایگان رسیدید','وصلت إلى حد الخطة المجانية','Has alcanzado el límite del plan gratuito','Vous avez atteint la limite de l’offre gratuite','Du hast das Limit des kostenlosen Tarifs erreicht','Você atingiu o limite do plano gratuito','Вы достигли лимита бесплатного тарифа','आप मुफ़्त प्लान की सीमा तक पहुंच गए हैं','已达到免费版上限'],
'purchaseSuccess': ['Purchase successful. Pro is now active.','خرید با موفقیت انجام شد. نسخه حرفه‌ای فعال است.','تمت عملية الشراء بنجاح. النسخة الاحترافية مفعّلة.','Compra realizada. Pro está activado.','Achat réussi. Pro est activé.','Kauf erfolgreich. Pro ist aktiviert.','Compra concluída. Pro ativado.','Покупка выполнена. Pro активирован.','खरीदारी सफल रही। प्रो सक्रिय है।','购买成功，专业版已激活。'],
'purchaseFailed': ['Purchase failed. Please try again.','خرید ناموفق بود. لطفاً دوباره تلاش کنید.','فشلت عملية الشراء. حاول مرة أخرى.','La compra falló. Inténtalo de nuevo.','L’achat a échoué. Réessayez.','Kauf fehlgeschlagen. Bitte erneut versuchen.','A compra falhou. Tente novamente.','Не удалось совершить покупку. Попробуйте снова.','खरीदारी विफल रही। कृपया फिर प्रयास करें।','购买失败，请重试。'],
'purchaseCancelled': ['Purchase cancelled.','خرید لغو شد.','تم إلغاء الشراء.','Compra cancelada.','Achat annulé.','Kauf abgebrochen.','Compra cancelada.','Покупка отменена.','खरीदारी रद्द की गई।','购买已取消。'],
'restoreNotFound': ['No previous purchase was found.','خرید قبلی پیدا نشد.','لم يتم العثور على عملية شراء سابقة.','No se encontró ninguna compra anterior.','Aucun achat précédent trouvé.','Kein früherer Kauf gefunden.','Nenhuma compra anterior encontrada.','Предыдущих покупок не найдено.','कोई पिछली खरीदारी नहीं मिली।','未找到之前的购买记录。'],
'cancel': ['Cancel','لغو','إلغاء','Cancelar','Annuler','Abbrechen','Cancelar','Отмена','रद्द करें','取消'],
}
for i, code in enumerate(L):
    path = f'lib/l10n/app_{code}.arb'
    if not os.path.exists(path):
        print(f'NOT FOUND: {path}')
        continue
    with open(path, encoding='utf-8') as f:
        d = json.load(f)
    for k, v in T.items():
        d[k] = v[i]
    with open(path, 'w', encoding='utf-8') as f:
        json.dump(d, f, ensure_ascii=False, indent=2)
    print(f'OK: {path}')
print('DONE')
