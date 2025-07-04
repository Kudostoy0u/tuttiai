import 'dart:ui';

class LocalizationService {
  // Define the order of supported languages. Index positions must align in the
  // translation lists below.
  static const List<String> _languages = [
    'English',
    'German',
    'Spanish',
    'French',
    'Italian',
    'Chinese',
    'Hindi',
  ];

  // Central translation table: each key maps to a list of translations
  // aligning with _languages order. If a translation is missing, leave it as
  // an empty string "" and English will be used as fallback.
  static const Map<String, List<String>> _keyTranslations = {
    // ----- General -----
    'settings': ['Settings', 'Einstellungen', 'Configuración', 'Paramètres', 'Impostazioni', '设置', 'सेटिंग्स'],
    'profile': ['Your Profile', 'Ihr Profil', 'Tu Perfil', 'Votre Profil', 'Il Tuo Profilo', '您的资料', 'आपकी प्रोफ़ाइल'],
    'preferences': ['Preferences', 'Präferenzen', 'Preferencias', 'Préférences', 'Preferenze', '偏好', 'प्राथमिकताएं'],
    'practice': ['Practice', 'Übung', 'Práctica', 'Pratique', 'Pratica', '练习', 'अभ्यास'],
    'support': ['Support', 'Support', 'Soporte', 'Support', 'Supporto', '支持', 'सहायता'],
    'account': ['Account', 'Konto', 'Cuenta', 'Compte', 'Account', '账户', 'खाता'],

    // ----- Navigation -----
    'home': ['Home', 'Start', 'Inicio', 'Accueil', 'Home', '主页', 'मुख्य'],
    'library': ['Library', 'Bibliothek', 'Biblioteca', 'Bibliothèque', 'Biblioteca', '图书馆', 'पुस्तकालय'],
    'community': ['Community', 'Gemeinschaft', 'Comunidad', 'Communauté', 'Comunità', '社区', 'समुदाय'],

    // ----- Dashboard feature titles -----
    'sheet_music_finder': ['Sheet Music\nFinder', 'Notensuche', 'Buscador de Partituras', 'Recherche de\nPartitions', 'Trova\nSpartiti', '乐谱查找', 'शीट संगीत खोज'],
    'recording_analyzer': ['Recording\nAnalyzer', 'Aufnahme\nAnalyse', 'Analizador de\nGrabaciones', 'Analyseur de\nRecordings', 'Analizzatore\nRegistrazioni', '录音分析', 'रिकॉर्डिंग विश्लेषक'],
    'listen': ['Listen', 'Hören', 'Escuchar', 'Écouter', 'Ascolta', '聆听', 'सुनें'],
    'metronome_feature': ['Metronome', 'Metronom', 'Metrónomo', 'Métronome', 'Metronomo', '节拍器', 'मेट्रोनोम'],
    'tuning_feature': ['Tuning', 'Stimmen', 'Afinación', 'Accordeur', 'Accordatura', '调音', 'ट्यूनिंग'],
    'community_videos': ['Community\nVideos', 'Community\nVideos', 'Videos de\nComunidad', 'Vidéos\nCommunauté', 'Video\nComunità', '社区视频', 'समुदाय वीडियो'],

    // ----- Dashboard feature descriptions -----
    'sheet_music_desc': ['AI-powered sheet music suggestions', 'KI-gestützte Notenempfehlungen', 'Sugerencias de partituras impulsadas por IA', 'Suggestions de partitions IA', 'Suggerimenti di spartiti con IA', 'AI乐谱推荐', 'एआई आधारित शीट संगीत सुझाव'],
    'recording_desc': ['Record and analyze your practice sessions.', 'Nehmen Sie Ihre Übungssitzungen auf und analysieren Sie sie.', 'Graba y analiza tus sesiones de práctica.', 'Enregistrez et analysez vos sessions de pratique.', 'Registra e analizza le tue sessioni di pratica.', '记录并分析您的练习', 'अपनी अभ्यास सत्र रिकॉर्ड करें और विश्लेषण करें।'],
    'listen_desc': ['Hear pieces or play with accompaniment', 'Stücke anhören oder mit Begleitung spielen', 'Escucha piezas o toca con acompañamiento', 'Écoutez des morceaux ou jouez avec accompagnement', 'Ascolta brani o suona con accompagnamento', '聆听曲目或伴奏演奏', 'रचनाएँ सुनें या संगत के साथ बजाएं'],
    'metronome_desc': ['Keep perfect time', 'Halten Sie perfektes Tempo', 'Mantén el tiempo perfecto', 'Gardez le tempo parfait', 'Mantieni il tempo perfetto', '保持完美节拍', 'सटीक समय रखें'],
    'tuning_desc': ['Tune your instrument with precision', 'Stimmen Sie Ihr Instrument präzise', 'Afina tu instrumento con precisión', 'Accordez votre instrument avec précision', 'Accorda il tuo strumento con precisione', '精准调音', 'अपने वाद्ययंत्र को सटीक रूप से ट्यून करें'],
    'community_desc': ['Get feedback from the community', 'Erhalten Sie Feedback von der Community', 'Obtén comentarios de la comunidad', 'Obtenez des retours de la communauté', 'Ottieni feedback dalla community', '获取社区反馈', 'समुदाय से प्रतिक्रिया प्राप्त करें'],

    // ----- Metronome labels -----
    'note_subdivision': ['Note Subdivision', 'Notenunterteilung', 'Subdivisión de Nota', 'Subdivision de note', 'Suddivisione della nota', '分音', 'सुबिभाजन'],
    'accent_pattern': ['Accent Pattern', 'Akzentmuster', 'Patrón de Acentos', 'Motif d\'accent', 'Pattern accentuazione', '重音模式', 'ऐक्सेंट पैटर्न'],
    'time_signature': ['Time Signature', 'Taktart', 'Compás', 'Signature temporelle', 'Tempo', '拍号', 'ताल चिह्न'],
    'audio_volume': ['Audio Volume', 'Lautstärke', 'Volumen de Audio', 'Volume audio', 'Volume audio', '音量', 'आडियो वॉल्यूम'],
    'haptic_feedback': ['Haptic Feedback', 'Haptisches Feedback', 'Retroalimentación Háptica', 'Retour haptique', 'Feedback aptico', '触觉反馈', 'हैप्टिक फीडबैक'],

    // ----- Settings help/feedback -----
    'help_desc': ['Get help with Tutti', 'Hilfe mit Tutti erhalten', 'Obtén ayuda con Tutti', 'Obtenez de l\'aide avec Tutti', 'Ottieni aiuto con Tutti', '获取 Tutti 帮助', 'Tutti के लिए सहायता प्राप्त करें'],
    'feedback_desc': ['Tell us how we can improve', 'Sagen Sie uns, wie wir uns verbessern können', 'Dinos cómo podemos mejorar', 'Dites-nous comment nous améliorer', 'Dicci come possiamo migliorare', '告诉我们如何改进', 'हमें बताएं कि हम कैसे सुधार कर सकते हैं'],

    // ----- Settings Options (added) -----
    'notifications': ['Notifications', 'Benachrichtigungen', 'Notificaciones', 'Notifications', 'Notifiche', '通知', 'अधिसूचनाएं'],
    'dark_mode': ['Dark Mode', 'Dunkler Modus', 'Modo Oscuro', 'Mode Sombre', 'Modalità Scura', '深色模式', 'डार्क मोड'],
    'language': ['Language', 'Sprache', 'Idioma', 'Langue', 'Lingua', '语言', 'भाषा'],
    'practice_reminders': ['Practice Reminders', 'Übungserinnerungen', 'Recordatorios de Práctica', 'Rappels de Pratique', 'Promemoria di Pratica', '练习提醒', 'अभ्यास रिमाइंडर'],
    'default_tuning': ['Default Tuning', 'Standard-Stimmung', 'Afinación por Defecto', 'Accordage par Défaut', 'Accordatura Predefinita', '默认调音', 'डिफ़ॉल्ट ट्यूनिंग'],
    'metronome_default_tempo': ['Metronome Default Tempo', 'Standard-Metronom-Tempo', 'Tempo por Defecto del Metrónomo', 'Tempo par Défaut du Métronome', 'Tempo Predefinito del Metronomo', '默认节拍器速度', 'डिफ़ॉल्ट मेट्रोनोम टेम्पो'],
    'help_faq': ['Help & FAQ', 'Hilfe & FAQ', 'Ayuda y Preguntas Frecuentes', 'Aide et FAQ', 'Aiuto e FAQ', '帮助和常见问题', 'सहायता और FAQ'],
    'send_feedback': ['Send Feedback', 'Feedback senden', 'Enviar Comentarios', 'Envoyer des Commentaires', 'Invia Feedback', '发送反馈', 'फीडबैक भेजें'],
    'about': ['About', 'Über', 'Acerca de', 'À Propos', 'Informazioni', '关于', 'के बारे में'],
    'sign_out': ['Sign Out', 'Abmelden', 'Cerrar Sesión', 'Se Déconnecter', 'Disconnettiti', '退出', 'साइन आउट'],

    // ----- Library tabs & search -----
    'sheet_music_tab': ['Sheet Music', 'Noten', 'Partituras', 'Partitions', 'Spartiti', '乐谱', 'शीट संगीत'],
    'recordings_tab': ['Recordings', 'Aufnahmen', 'Grabaciones', 'Enregistrements', 'Registrazioni', '录音', 'रिकॉर्डिंग्स'],
    'practice_log_tab': ['Practice Log', 'Übungsprotokoll', 'Registro de Práctica', 'Journal de Pratique', 'Registro Pratica', '练习日志', 'अभ्यास लॉग'],
    'search_sheet_music': ['Search sheet music...', 'Noten durchsuchen...', 'Buscar partituras...', 'Rechercher des partitions...', 'Cerca spartiti...', '搜索乐谱...', 'शीट संगीत खोजें...'],
    'search_recordings': ['Search recordings...', 'Aufnahmen durchsuchen...', 'Buscar grabaciones...', 'Rechercher des enregistrements...', 'Cerca registrazioni...', '搜索录音...', 'रिकॉर्डिंग खोजें...'],
    'recently_added': ['Recently Added', 'Kürzlich hinzugefügt', 'Recientemente Agregado', 'Récemment ajouté', 'Aggiunti di recente', '最近添加', 'हाल में जोड़ा गया'],
    'all': ['All', 'Alle', 'Todo', 'Tout', 'Tutto', '全部', 'सभी'],
    'favorites': ['Favorites', 'Favoriten', 'Favoritos', 'Favoris', 'Preferiti', '收藏', 'पसंदीदा'],

    // ----- Dashboard Greeting -----
    'welcome_back': ['Welcome Back', 'Willkommen zurück', 'Bienvenido', 'Bon Retour', 'Bentornato', '欢迎回来', 'वापस स्वागत है'],

    // ----- Status words -----
    'enabled': ['Enabled', 'Aktiviert', 'Habilitado', 'Activé', 'Abilitato', '已启用', 'सक्षम'],
    'disabled': ['Disabled', 'Deaktiviert', 'Deshabilitado', 'Désactivé', 'Disabilitato', '已禁用', 'निष्क्रिय'],
    'version': ['Version', 'Version', 'Versión', 'Version', 'Versione', '版本', 'संस्करण'],
    'sign_out_desc': ['Sign out of your account', 'Melden Sie sich von Ihrem Konto ab', 'Cierra tu sesión', 'Déconnectez-vous de votre compte', 'Esci dal tuo account', '退出您的账户', 'अपने खाते से साइन आउट करें'],

    // ----- Tuner page -----
    'tuner': ['Tuner', 'Stimmer', 'Afinador', 'Accordeur', 'Accordatore', '调音器', 'ट्यूनर'],
    'select_instrument': ['Select Instrument', 'Instrument wählen', 'Selecciona instrumento', 'Sélectionnez l\'instrument', 'Seleziona strumento', '选择乐器', 'वाद्य यंत्र चुनें'],
    'select_string': ['Select String', 'Saite wählen', 'Selecciona cuerda', 'Sélectionnez la corde', 'Seleziona corda', '选择弦', 'स्ट्रिंग चुनें'],

    // ----- Additional Tuner & Recording -----
    'octave': ['Octave', 'Oktave', 'Octava', 'Octave', 'Ottava', '八度', 'ऑक्टेव'],
    'reference': ['Reference', 'Referenz', 'Referencia', 'Référence', 'Riferimento', '参考音', 'संदर्भ'],
    'start': ['Start', 'Start', 'Iniciar', 'Démarrer', 'Avvia', '开始', 'शुरू'],
    'stop': ['Stop', 'Stopp', 'Detener', 'Arrêter', 'Ferma', '停止', 'रोकें'],
    'no_recordings': ['No recordings yet', 'Noch keine Aufnahmen', 'Aún no hay grabaciones', 'Pas d\'enregistrements', 'Nessuna registrazione', '暂无录音', 'अभी कोई रिकॉर्डिंग नहीं'],
    'rename': ['Rename', 'Umbenennen', 'Renombrar', 'Renommer', 'Rinomina', '重命名', 'नाम बदलें'],
    'delete': ['Delete', 'Löschen', 'Eliminar', 'Supprimer', 'Elimina', '删除', 'हटाएं'],
    'today': ['Today', 'Heute', 'Hoy', 'Aujourd\'hui', 'Oggi', '今天', 'आज'],
    'yesterday': ['Yesterday', 'Gestern', 'Ayer', 'Hier', 'Ieri', '昨天', 'कल'],
    'days_ago': ['days ago', 'Tage her', 'días atrás', 'jours plus tôt', 'giorni fa', '天前', 'दिन पहले'],
    'recording_analyzer_title': ['Recording Analyzer', 'Aufnahmeanalyse', 'Analizador de Grabaciones', 'Analyseur d\'enregistrements', 'Analizzatore Registrazioni', '录音分析', 'रिकॉर्डिंग विश्लेषक'],
    'sheet_music_finder_title': ['Sheet Music Finder', 'Notensuche', 'Buscador de Partituras', 'Recherche de Partitions', 'Trova Spartiti', '乐谱查找', 'शीट संगीत खोज'],
    'metronome_title': ['Metronome', 'Metronom', 'Metrónomo', 'Métronome', 'Metronomo', '节拍器', 'मेट्रोनोम'],
    'target_note': ['Target Note', 'Zielnote', 'Nota Objetivo', 'Note Cible', 'Nota Obiettivo', '目标音符', 'लक्ष्य नोट'],
    'target_frequency': ['Target Frequency', 'Zielfrequenz', 'Frecuencia Objetivo', 'Fréquence Cible', 'Frequenza Obiettivo', '目标频率', 'लक्ष्य आवृत्ति'],
    'none_pattern': ['None','Keine','Ninguno','Aucun','Nessuno','无','कोई नहीं'],
    'first_beat_pattern': ['First Beat','Erster Schlag','Primer Pulso','Premier temps','Primo battito','第一拍','पहलीबीट'],
    'strong_weak_pattern': ['Strong-Weak','Stark-Schwach','Fuerte-Débil','Fort-Faible','Forte-Debole','强-弱','मजबूत-कमजोर'],
    'waltz_pattern': ['Waltz','Walzer','Vals','Valse','Valzer','华尔兹','वाल्ट्ज'],
    'march_pattern': ['March','Marsch','Marcha','Marche','Marcia','进行曲','मार्च'],
    'complex_pattern': ['Complex','Komplex','Complejo','Complexe','Complesso','复杂','जटिल'],

    // ----- Instrument Names -----
    'instrument_violin': ['Violin', 'Violine', 'Violín', 'Violon', 'Violino', '小提琴', 'वायलिन'],
    'instrument_viola': ['Viola', 'Bratsche', 'Viola', 'Alto', 'Viola', '中提琴', 'वीओला'],
    'instrument_cello': ['Cello', 'Cello', 'Violoncelo', 'Violoncelle', 'Violoncello', '大提琴', 'चेलो'],
    'instrument_double_bass': ['Double Bass', 'Kontrabass', 'Contrabajo', 'Contrebasse', 'Contrabbasso', '低音提琴', 'डबल बास'],
    'instrument_guitar': ['Guitar', 'Gitarre', 'Guitarra', 'Guitare', 'Chitarra', '吉他', 'गिटार'],
    'instrument_flute': ['Flute', 'Flöte', 'Flauta', 'Flûte', 'Flauto', '长笛', 'बांसुरी'],
    'instrument_oboe': ['Oboe', 'Oboe', 'Oboe', 'Hautbois', 'Oboe', '双簧管', 'ओबो'],
    'instrument_clarinet': ['Clarinet', 'Klarinette', 'Clarinete', 'Clarinette', 'Clarinetto', '单簧管', 'क्लैरिनेट'],
    'instrument_trumpet': ['Trumpet', 'Trompete', 'Trompeta', 'Trompette', 'Tromba', '小号', 'तुरही'],
    'instrument_french_horn': ['French Horn', 'Waldhorn', 'Trompa', 'Cor', 'Corno Francese', '圆号', 'फ्रेंच हॉर्न'],
    'instrument_trombone': ['Trombone', 'Posaune', 'Trombón', 'Trombone', 'Trombone', '长号', 'ट्रॉम्बोन'],

    // ----- Time Units -----
    'hrs': ['hrs', 'Std', 'h', 'h', 'h', '小时', 'घंटे'],
    'min_unit': ['min', 'Min', 'min', 'min', 'min', '分', 'मिनट'],
    'days_unit': ['days', 'Tage', 'días', 'jours', 'giorni', '天', 'दिन'],

    // ----- Sheet Music Finder -----
    'personalized_for_you': ['Personalized for You', 'Für Sie personalisiert', 'Personalizado para ti', 'Personnalisé pour vous', 'Personalizzato per te', '为你个性化', 'आपके लिए निजीकृत'],
    'based_on_skill': ['Based on your skill level, preferences, and practice history', 'Basierend auf Ihrem Fähigkeitslevel, Ihren Präferenzen und Ihrer Übungshistorie', 'Basado en tu nivel, preferencias e historial de práctica', 'Basé sur votre niveau, vos préférences et votre historique de pratique', 'Basato sul tuo livello, preferenze e cronologia di pratica', '基于你的水平、偏好和练习历史', 'आपके कौशल स्तर, पसंद और अभ्यास इतिहास के आधार पर'],
    'ai_analyzing_prefs': ['AI is analyzing your preferences...', 'KI analysiert Ihre Präferenzen...', 'La IA está analizando tus preferencias...', 'L\'IA analyse vos préférences...', 'L\'IA sta analizzando le tue preferenze...', 'AI 正在分析你的喜好...', 'एआई आपकी पसंद का विश्लेषण कर रही है...'],
    'match_word': ['Match', 'Treffer', 'Coincidencia', 'Correspondance', 'Corrispondenza', '匹配', 'मिलान'],
    'add_to_library': ['Add to Library', 'Zur Bibliothek hinzufügen', 'Agregar a la biblioteca', 'Ajouter à la bibliothèque', 'Aggiungi alla libreria', '添加到资料库', 'लाइब्रेरी में जोड़ें'],
    'added_to_library': ['Added to your library', 'Zur Bibliothek hinzugefügt', 'Añadido a tu biblioteca', 'Ajouté à votre bibliothèque', 'Aggiunto alla tua libreria', '已添加到你的资料库', 'आपकी लाइब्रेरी में जोड़ा गया'],
    'difficulty_beginner': ['Beginner', 'Anfänger', 'Principiante', 'Débutant', 'Principiante', '初学者', 'शुरुआती'],
    'difficulty_intermediate': ['Intermediate', 'Mittelstufe', 'Intermedio', 'Intermédiaire', 'Intermedio', '中级', 'मध्यम'],
    'difficulty_advanced': ['Advanced', 'Fortgeschritten', 'Avanzado', 'Avancé', 'Avanzato', '高级', 'उन्नत'],
    'h_unit': ['h', 'Std', 'h', 'h', 'h', '小时', 'घं'],
    'm_unit': ['m', 'Min', 'm', 'min', 'min', '分', 'मि'],
    'no_skill_level_set': ['No skill level set', 'Kein Fertigkeitslevel festgelegt', 'Sin nivel de habilidad', 'Aucun niveau de compétence défini', 'Nessun livello di abilità impostato', '未设置技能水平', 'कोई कौशल स्तर निर्धारित नहीं'],
    'this_week': ['This Week', 'Diese Woche', 'Esta Semana', 'Cette semaine', 'Questa settimana', '本周', 'इस सप्ताह'],
    'streak': ['Streak', 'Serie', 'Racha', 'Série', 'Serie', '连胜', 'स्ट्रिक'],

    // ----- Edit Profile -----
    'edit_profile_title': ['Edit Profile','Profil bearbeiten','Editar perfil','Modifier le profil','Modifica profilo','编辑个人资料','प्रोफ़ाइल संपादित करें'],
    'basic_information': ['Basic Information','Grundinformationen','Información básica','Informations de base','Informazioni di base','基本信息','मूल जानकारी'],
    'musical_preferences': ['Musical Preferences','Musikalische Präferenzen','Preferencias musicales','Préférences musicales','Preferenze musicali','音乐偏好','संगीत वरीयताएँ'],
    'subscription_billing': ['Subscription & Billing','Abonnement & Abrechnung','Suscripción y facturación','Abonnement et facturation','Abbonamento e fatturazione','订阅和账单','सदस्यता और बिलिंग'],
    'full_name': ['Full Name','Vollständiger Name','Nombre completo','Nom complet','Nome completo','全名','पूरा नाम'],
    'email': ['Email','E-Mail','Correo electrónico','E-mail','Email','电子邮件','ईमेल'],
    'new_password_optional': ['New Password (optional)','Neues Passwort (optional)','Nueva contraseña (opcional)','Nouveau mot de passe (facultatif)','Nuova password (opzionale)','新密码（可选）','नया पासवर्ड (वैकल्पिक)'],
    'confirm_new_password': ['Confirm New Password','Neues Passwort bestätigen','Confirmar nueva contraseña','Confirmer le nouveau mot de passe','Conferma nuova password','确认新密码','नया पासवर्ड पुष्टि करें'],
    'save_basic_information': ['Save Basic Information','Grundinformationen speichern','Guardar información básica','Enregistrer les informations de base','Salva informazioni di base','保存基本信息','मूल जानकारी सहेजें'],
    'update_musical_preferences': ['Update Musical Preferences','Musikalische Präferenzen aktualisieren','Actualizar preferencias musicales','Mettre à jour les préférences musicales','Aggiorna preferenze musicali','更新音乐偏好','संगीत वरीयताएँ अपडेट करें'],
    'instrument_label': ['Instrument','Instrument','Instrumento','Instrument','Strumento','乐器','वाद्य यंत्र'],
    'skill_level_label': ['Skill Level','Fähigkeitslevel','Nivel de habilidad','Niveau de compétence','Livello di abilità','技能水平','कौशल स्तर'],
    'practice_frequency_label': ['Practice Frequency','Übungshäufigkeit','Frecuencia de práctica','Fréquence de pratique','Frequenza di pratica','练习频率','अभ्यास आवृत्ति'],
    'genres_label': ['Genres','Genres','Géneros','Genres','Generi','流派','शैलियाँ'],
    'not_set': ['Not set','Nicht festgelegt','No establecido','Non défini','Non impostato','未设置','सेट नहीं'],
    'no_name_set': ['No name set','Kein Name festgelegt','Sin nombre','Aucun nom','Nessun nome','没有名称','कोई नाम नहीं'],

    // Payment & Subscription
    'payment_method': ['Payment Method','Zahlungsmethode','Método de pago','Mode de paiement','Metodo di pagamento','支付方式','भुगतान विधि'],
    'manage_payment_methods': ['Manage your payment methods','Verwalten Sie Ihre Zahlungsmethoden','Gestiona tus métodos de pago','Gérez vos moyens de paiement','Gestisci i tuoi metodi di pagamento','管理您的付款方式','अपनी भुगतान विधियाँ प्रबंधित करें'],
    'billing_history': ['Billing History','Rechnungsverlauf','Historial de facturación','Historique de facturation','Storico fatturazione','账单历史','बिलिंग इतिहास'],
    'view_past_invoices': ['View past invoices','Vergangene Rechnungen anzeigen','Ver facturas pasadas','Voir les factures passées','Visualizza fatture passate','查看过去的发票','पिछले इनवॉइस देखें'],
    'subscription_plan': ['Subscription Plan','Abonnement','Plan de suscripción','Offre d\'abonnement','Piano di abbonamento','订阅计划','सदस्यता योजना'],
    'free_plan': ['Free Plan','Kostenloser Plan','Plan gratuito','Offre gratuite','Piano gratuito','免费计划','निःशुल्क योजना'],
    'coming_soon': ['Coming soon','Demnächst','Próximamente','Bientôt disponible','Prossimamente','即将推出','जल्द आ रहा है'],
  };

  // Build per-language map programmatically
  static final Map<String, Map<String, String>> _translations = () {
    final Map<String, Map<String, String>> result = {
      for (final lang in _languages) lang: {}
    };

    _keyTranslations.forEach((key, translations) {
      for (int i = 0; i < _languages.length; i++) {
        final lang = _languages[i];
        final value = i < translations.length && translations[i].isNotEmpty
            ? translations[i]
            : translations[0]; // fallback to English version
        result[lang]![key] = value;
      }
    });

    return result;
  }();

  static String translate(String key, String language) {
    return _translations[language]?[key] ?? key;
  }

  static Locale getLocale(String language) {
    switch (language) {
      case 'German':
        return const Locale('de', 'DE');
      case 'Spanish':
        return const Locale('es', 'ES');
      case 'French':
        return const Locale('fr', 'FR');
      case 'Italian':
        return const Locale('it', 'IT');
      case 'Chinese':
        return const Locale('zh', 'CN');
      case 'Hindi':
        return const Locale('hi', 'IN');
      default:
        return const Locale('en', 'US');
    }
  }
}

// Extension helper
extension StringTranslation on String {
  String tr(String language) => LocalizationService.translate(this, language);
} 