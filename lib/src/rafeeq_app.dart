import 'dart:async';

import 'package:flutter/material.dart';

import 'models/activity_log.dart';
import 'models/app_screen.dart';
import 'models/app_user.dart';
import 'models/caregiver_alert.dart';
import 'models/check_in.dart';
import 'models/dose_log.dart';
import 'models/medication.dart';
import 'models/medication_status.dart';
import 'models/scheduled_dose.dart';
import 'models/user_role.dart';
import 'repositories/activity_repository.dart';
import 'repositories/alert_repository.dart';
import 'repositories/check_in_repository.dart';
import 'repositories/dose_log_repository.dart';
import 'repositories/medication_repository.dart';
import 'repositories/user_repository.dart';
import 'screens/rafeeq_screens.dart';
import 'services/auth_service.dart';
import 'services/messaging_service.dart';
import 'services/notification_service.dart';
import 'theme/app_colors.dart';
import 'widgets/rafeeq_widgets.dart';

export 'models/app_screen.dart';
export 'screens/rafeeq_screens.dart';
export 'widgets/rafeeq_widgets.dart';

class RafeeqApp extends StatelessWidget {
  const RafeeqApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'رفيق كبار السن',
      locale: const Locale('ar'),
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.surface,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          primary: AppColors.primary,
          secondary: AppColors.secondary,
          surface: AppColors.surface,
          error: AppColors.error,
        ),
        fontFamily: 'sans',
        textTheme: const TextTheme(
          headlineLarge: TextStyle(fontWeight: FontWeight.w900),
          headlineMedium: TextStyle(fontWeight: FontWeight.w900),
          titleLarge: TextStyle(fontWeight: FontWeight.w800),
          titleMedium: TextStyle(fontWeight: FontWeight.w800),
          bodyLarge: TextStyle(fontWeight: FontWeight.w500),
        ),
      ),
      home: const Directionality(
        textDirection: TextDirection.rtl,
        child: RafeeqShell(),
      ),
    );
  }
}

class RafeeqShell extends StatefulWidget {
  const RafeeqShell({super.key});

  @override
  State<RafeeqShell> createState() => _RafeeqShellState();
}

class _RafeeqShellState extends State<RafeeqShell> {
  AppScreen screen = AppScreen.login;
  bool initializing = true;

  final authService = AuthService();
  final userRepository = UserRepository();
  final medicationRepository = MedicationRepository();
  final activityRepository = ActivityRepository();
  final alertRepository = AlertRepository();
  final checkInRepository = CheckInRepository();
  final doseLogRepository = DoseLogRepository();
  final messagingService = MessagingService.instance;
  final notificationService = NotificationService.instance;

  StreamSubscription<List<Medication>>? medicationSubscription;
  StreamSubscription<CheckIn?>? checkInSubscription;
  StreamSubscription<List<DoseLog>>? doseLogSubscription;
  StreamSubscription<List<ActivityLog>>? activitySubscription;
  StreamSubscription<List<CaregiverAlert>>? alertSubscription;

  AppUser? currentUser;
  AppUser? selectedElderly;
  List<AppUser> linkedElderly = const [];
  List<Medication> medications = const [];
  List<DoseLog> doseLogs = const [];
  List<ScheduledDose> todayDoses = const [];
  List<ActivityLog> activities = const [];
  List<CaregiverAlert> alerts = const [];
  Medication? selectedMedication;
  ScheduledDose? selectedDose;
  bool checkedInToday = false;
  bool markingMissedDoses = false;
  bool alertStreamInitialized = false;
  Set<String> seenAlertIds = {};

  UserRole? get role => currentUser?.role;
  String? get dataOwnerId => selectedElderly?.id;
  bool get caregiverHasPatient =>
      currentUser?.role == UserRole.caregiver && selectedElderly != null;

  @override
  void initState() {
    super.initState();
    restoreSession();
  }

  void navigate(AppScreen next) {
    if (next == AppScreen.medicationDetail && selectedMedication == null) {
      if (todayDoses.isEmpty && medications.isEmpty) {
        showDataError('لا توجد أدوية لعرضها حالياً.');
        return;
      }
      selectedDose = _nextPendingDose();
      selectedMedication = selectedDose?.medication ?? medications.first;
    }
    setState(() => screen = next);
  }

  Future<void> restoreSession() async {
    final firebaseUser = authService.currentUser;
    if (firebaseUser == null) {
      if (!mounted) return;
      setState(() {
        initializing = false;
        screen = AppScreen.login;
      });
      return;
    }

    try {
      final user = await userRepository.getById(firebaseUser.uid);
      if (user == null) {
        await authService.signOut();
        if (!mounted) return;
        setState(() {
          initializing = false;
          screen = AppScreen.login;
        });
        return;
      }

      await enterApp(user);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        initializing = false;
        screen = AppScreen.login;
      });
    }
  }

  Future<void> signIn(String email, String password) async {
    try {
      final credential = await authService.signIn(
        email: email.trim(),
        password: password,
      );
      final firebaseUser = credential.user;
      if (firebaseUser == null) return;

      final user = await userRepository.getForSignIn(firebaseUser);
      if (user == null) {
        await authService.signOut();
        showDataError(
            'لا يوجد ملف لهذا الحساب. يرجى إنشاء حساب من داخل التطبيق.');
        return;
      }
      await enterApp(user);
    } catch (_) {
      showDataError('تعذر تسجيل الدخول. تأكد من البريد وكلمة المرور.');
    }
  }

  Future<void> signUp({
    required String name,
    required String email,
    required String password,
    required UserRole role,
  }) async {
    if (name.trim().isEmpty || email.trim().isEmpty || password.length < 6) {
      showDataError('أكمل الاسم والبريد وكلمة مرور من ستة أحرف على الأقل.');
      return;
    }

    try {
      final credential = await authService.signUp(
        name: name.trim(),
        email: email.trim(),
        password: password,
      );
      final firebaseUser = authService.currentUser ?? credential.user;
      if (firebaseUser == null) return;

      final user = await userRepository.getOrCreate(
        firebaseUser: firebaseUser,
        fallbackRole: role,
      );
      await enterApp(user);
    } catch (_) {
      showDataError('تعذر إنشاء الحساب. تحقق من البيانات وحاول مرة أخرى.');
    }
  }

  Future<void> enterApp(AppUser user) async {
    await registerMessagingToken(user);

    if (user.role == UserRole.elderly) {
      selectedElderly = user;
      if (!mounted) return;
      setState(() {
        initializing = false;
        currentUser = user;
        linkedElderly = const [];
        screen = AppScreen.home;
      });
      bindUserData(user.id);
      return;
    }

    final patients = await userRepository.getUsersByIds(user.elderlyIds);
    final firstPatient = patients.isEmpty ? null : patients.first;
    selectedElderly = firstPatient;
    if (!mounted) return;
    setState(() {
      initializing = false;
      currentUser = user;
      linkedElderly = patients;
      screen = AppScreen.caregiverDashboard;
    });
    bindUserData(firstPatient?.id);
  }

  Future<void> selectDataOwner(AppUser? elderly) async {
    selectedElderly = elderly;
    await bindUserData(elderly?.id);
  }

  Future<void> bindUserData(String? ownerId) async {
    await medicationSubscription?.cancel();
    await checkInSubscription?.cancel();
    await doseLogSubscription?.cancel();
    await activitySubscription?.cancel();
    await alertSubscription?.cancel();

    if (ownerId == null) {
      if (!mounted) return;
      setState(() {
        medications = const [];
        checkedInToday = false;
        doseLogs = const [];
        todayDoses = const [];
        activities = const [];
        alerts = const [];
        selectedMedication = null;
        selectedDose = null;
        alertStreamInitialized = false;
        seenAlertIds = {};
      });
      return;
    }

    medicationSubscription = medicationRepository.watchAll(ownerId).listen(
      (items) {
        if (!mounted) return;
        scheduleLocalMedicationReminders(ownerId, items);
        setState(() {
          medications = items;
          todayDoses = doseLogRepository.buildTodayDoses(
            medications: items,
            logs: doseLogs,
          );
          if (selectedMedication != null) {
            selectedMedication = _findMedicationById(
              items,
              selectedMedication!.id,
            );
            if (selectedDose != null) {
              selectedDose = _findDoseById(selectedDose!.id);
            }
          }
        });
        markOverdueDosesMissed(ownerId);
      },
      onError: (_) => showDataError('تعذر تحميل الأدوية. حاول مرة أخرى.'),
    );

    checkInSubscription = checkInRepository.watchToday(ownerId).listen(
      (checkIn) {
        if (!mounted) return;
        setState(() => checkedInToday = checkIn?.isOk == true);
      },
      onError: (_) => showDataError('تعذر تحميل حالة الاطمئنان اليومية.'),
    );

    doseLogSubscription = doseLogRepository
        .watchForDate(ownerId, DoseLogRepository.formatDate(DateTime.now()))
        .listen(
      (items) {
        if (!mounted) return;
        setState(() {
          doseLogs = items;
          todayDoses = doseLogRepository.buildTodayDoses(
            medications: medications,
            logs: items,
          );
          if (selectedDose != null) {
            selectedDose = _findDoseById(selectedDose!.id);
            selectedMedication = selectedDose?.medication ?? selectedMedication;
          }
        });
        markOverdueDosesMissed(ownerId);
      },
      onError: (_) => showDataError('تعذر تحميل جرعات اليوم. حاول مرة أخرى.'),
    );

    activitySubscription = activityRepository.watchRecent(ownerId).listen(
      (items) {
        if (!mounted) return;
        setState(() => activities = items);
      },
      onError: (_) => showDataError('تعذر تحميل سجل النشاط. حاول مرة أخرى.'),
    );

    alertSubscription = alertRepository.watchOpenAlerts(ownerId).listen(
      (items) {
        if (!mounted) return;
        handleIncomingAlerts(items);
        setState(() => alerts = items);
      },
      onError: (_) {
        if (!mounted) return;
        setState(() => alerts = const []);
      },
    );
  }

  void showDataError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> registerMessagingToken(AppUser user) async {
    try {
      await messagingService.registerUser(
        userId: user.id,
        userRepository: userRepository,
      );
    } catch (_) {
      // Token registration should not block sign-in or core app use.
    }
  }

  void handleIncomingAlerts(List<CaregiverAlert> items) {
    if (currentUser?.role != UserRole.caregiver) {
      seenAlertIds = items.map((item) => item.id).toSet();
      alertStreamInitialized = true;
      return;
    }

    final currentIds = items.map((item) => item.id).toSet();
    if (!alertStreamInitialized) {
      seenAlertIds = currentIds;
      alertStreamInitialized = true;
      return;
    }

    final newAlerts = items.where((item) => !seenAlertIds.contains(item.id));
    seenAlertIds = currentIds;

    for (final alert in newAlerts) {
      notificationService.showCaregiverAlertNotification(alert);
    }
  }

  void selectMedication(Medication medication) => setState(() {
        selectedMedication = medication;
        selectedDose = null;
        screen = AppScreen.medicationDetail;
      });

  void selectDose(ScheduledDose dose) => setState(() {
        selectedDose = dose;
        selectedMedication = dose.medication;
        screen = AppScreen.medicationDetail;
      });

  Future<void> selectPatient(AppUser patient) async {
    await selectDataOwner(patient);
    if (!mounted) return;
    setState(() => selectedElderly = patient);
  }

  Future<void> linkElderlyByCode(String code) async {
    final caregiver = currentUser;
    if (caregiver == null || caregiver.role != UserRole.caregiver) return;

    try {
      final patient = await userRepository.linkCaregiverByCode(
        caregiverId: caregiver.id,
        code: code,
      );
      if (patient == null) {
        showDataError('رمز الربط غير صحيح أو غير نشط.');
        return;
      }

      final refreshedCaregiver = await userRepository.getById(caregiver.id);
      final patients = refreshedCaregiver == null
          ? [...linkedElderly, patient]
          : await userRepository.getUsersByIds(refreshedCaregiver.elderlyIds);

      await selectDataOwner(patient);
      if (!mounted) return;
      setState(() {
        currentUser = refreshedCaregiver ?? caregiver;
        linkedElderly = patients;
        selectedElderly = patient;
        screen = AppScreen.caregiverDashboard;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تمت إضافة ${patient.name} بنجاح.')),
      );
    } catch (_) {
      showDataError('تعذر إضافة المسن. حاول مرة أخرى.');
    }
  }

  Future<void> updateMedicationStatus(
    Medication medication,
    MedicationStatus status,
  ) async {
    final ownerId = dataOwnerId;
    if (ownerId == null) {
      showDataError('اختر مسناً أولاً.');
      return;
    }

    try {
      await medicationRepository.updateStatus(
        userId: ownerId,
        medicationId: medication.id,
        status: status,
      );
      await activityRepository.addMedicationStatusChange(
        userId: ownerId,
        medication: medication,
        status: status,
        userName: currentUser?.name ?? '',
      );
      if (!mounted) return;
      setState(() {
        selectedMedication = medication.copyWith(status: status);
        screen = currentUser?.role == UserRole.caregiver
            ? AppScreen.caregiverDashboard
            : AppScreen.home;
      });
    } catch (_) {
      showDataError('تعذر تحديث حالة الدواء.');
    }
  }

  Future<void> updateDoseStatus(
    ScheduledDose dose,
    MedicationStatus status,
  ) async {
    final ownerId = dataOwnerId;
    if (ownerId == null) {
      showDataError('اختر مسناً أولاً.');
      return;
    }

    try {
      await doseLogRepository.upsertStatus(
        userId: ownerId,
        dose: dose,
        status: status,
      );
      await activityRepository.addMedicationStatusChange(
        userId: ownerId,
        medication: dose.medication.copyWith(time: dose.scheduledTime),
        status: status,
        userName: currentUser?.name ?? '',
      );
      if (!mounted) return;
      setState(() {
        selectedDose = dose;
        selectedMedication = dose.medication;
        screen = currentUser?.role == UserRole.caregiver
            ? AppScreen.caregiverDashboard
            : AppScreen.home;
      });
    } catch (_) {
      showDataError('تعذر تحديث حالة الجرعة.');
    }
  }

  Future<void> checkIn() async {
    final ownerId = dataOwnerId;
    if (ownerId == null) return;

    try {
      await checkInRepository.saveToday(userId: ownerId);
      await activityRepository.addCheckIn(
        ownerId,
        userName: currentUser?.name ?? '',
      );
      if (!mounted) return;
      setState(() => checkedInToday = true);
    } catch (_) {
      showDataError('تعذر تسجيل الاطمئنان اليومي.');
    }
  }

  Future<void> addMedication(Medication medication) async {
    final ownerId = dataOwnerId;
    if (ownerId == null) {
      showDataError('أضف مسناً قبل إضافة الدواء.');
      return;
    }

    try {
      final savedMedication =
          await medicationRepository.add(ownerId, medication);
      if (currentUser?.role == UserRole.elderly) {
        await scheduleLocalMedicationReminders(ownerId, [savedMedication]);
      }
      if (!mounted) return;
      setState(() => screen = AppScreen.caregiverDashboard);
    } catch (_) {
      showDataError('تعذر حفظ الدواء.');
    }
  }

  Future<void> scheduleLocalMedicationReminders(
    String ownerId,
    List<Medication> items,
  ) async {
    if (currentUser?.role != UserRole.elderly || currentUser?.id != ownerId) {
      return;
    }

    try {
      await notificationService.scheduleMedicationReminders(
        elderlyUserId: ownerId,
        medications: items,
      );
    } catch (_) {
      if (!mounted) return;
      showDataError('تعذر جدولة تذكيرات الدواء على هذا الجهاز.');
    }
  }

  Future<void> markOverdueDosesMissed(String ownerId) async {
    if (markingMissedDoses || todayDoses.isEmpty) return;

    markingMissedDoses = true;
    try {
      final missedDoses = await doseLogRepository.markOverdueDosesMissed(
        userId: ownerId,
        doses: todayDoses,
      );
      await createMissedDoseAlerts(ownerId, missedDoses);
    } catch (_) {
      if (!mounted) return;
      showDataError('تعذر تحديث الجرعات الفائتة.');
    } finally {
      markingMissedDoses = false;
    }
  }

  Future<void> createMissedDoseAlerts(
    String ownerId,
    List<ScheduledDose> missedDoses,
  ) async {
    if (missedDoses.isEmpty) return;

    final elderly = selectedElderly?.id == ownerId
        ? selectedElderly
        : currentUser?.id == ownerId
            ? currentUser
            : null;
    final caregiverIds = elderly?.caregiverIds ?? const [];
    if (elderly == null || caregiverIds.isEmpty) return;

    for (final dose in missedDoses) {
      await alertRepository.createMissedDoseAlerts(
        elderlyUserId: ownerId,
        elderlyName: elderly.name,
        caregiverIds: caregiverIds,
        dose: dose,
      );
    }
  }

  Future<void> logout() async {
    await medicationSubscription?.cancel();
    await checkInSubscription?.cancel();
    await doseLogSubscription?.cancel();
    await activitySubscription?.cancel();
    await alertSubscription?.cancel();
    await messagingService.dispose();
    await authService.signOut();
    if (!mounted) return;
    setState(() {
      currentUser = null;
      selectedElderly = null;
      linkedElderly = const [];
      screen = AppScreen.login;
      medications = const [];
      checkedInToday = false;
      doseLogs = const [];
      todayDoses = const [];
      activities = const [];
      alerts = const [];
      selectedMedication = null;
      selectedDose = null;
      alertStreamInitialized = false;
      seenAlertIds = {};
      checkedInToday = false;
    });
  }

  @override
  void dispose() {
    medicationSubscription?.cancel();
    checkInSubscription?.cancel();
    doseLogSubscription?.cancel();
    activitySubscription?.cancel();
    alertSubscription?.cancel();
    unawaited(messagingService.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (initializing) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final patientName = selectedElderly?.name ?? 'من ترعاه';

    final child = switch (screen) {
      AppScreen.welcome => WelcomeScreen(
          onStart: () => navigate(AppScreen.login),
          onCaregiver: () => navigate(AppScreen.login),
        ),
      AppScreen.login => LoginScreen(
          onLogin: signIn,
          onSignUp: () => navigate(AppScreen.signUp),
        ),
      AppScreen.signUp => SignUpScreen(
          onBack: () => navigate(AppScreen.login),
          onCreateAccount: signUp,
        ),
      AppScreen.home => HomeScreen(
          doses: todayDoses,
          checkedInToday: checkedInToday,
          userName: currentUser?.name ?? 'مرحباً',
          careLinkCode: currentUser?.role == UserRole.elderly
              ? currentUser?.careLinkCode
              : null,
          onCheckIn: checkIn,
          onMedicationClick: selectDose,
          onTaken: (dose) => updateDoseStatus(dose, MedicationStatus.taken),
          onPostpone: (dose) =>
              updateDoseStatus(dose, MedicationStatus.postponed),
          onLogout: logout,
        ),
      AppScreen.medicationDetail => MedicationDetailScreen(
          medication: selectedMedication ?? _emptyMedication,
          onBack: () => navigate(AppScreen.home),
          onTaken: (medication) {
            final dose = selectedDose;
            if (dose != null) {
              updateDoseStatus(dose, MedicationStatus.taken);
            } else {
              updateMedicationStatus(medication, MedicationStatus.taken);
            }
          },
          onPostpone: (medication) {
            final dose = selectedDose;
            if (dose != null) {
              updateDoseStatus(dose, MedicationStatus.postponed);
            } else {
              updateMedicationStatus(medication, MedicationStatus.postponed);
            }
          },
        ),
      AppScreen.history => HistoryScreen(
          doses: todayDoses,
          onBack: () => navigate(AppScreen.home),
        ),
      AppScreen.caregiverDashboard => CaregiverDashboard(
          activities: activities,
          alerts: alerts,
          patients: linkedElderly,
          patientName: patientName,
          selectedPatientId: selectedElderly?.id,
          isLinked: caregiverHasPatient,
          onPatientSelected: selectPatient,
          onAlertsClick: () => navigate(AppScreen.caregiverAlerts),
          onAddElderlyClick: () => navigate(AppScreen.addElderly),
          onAddMedicationClick: caregiverHasPatient
              ? () => navigate(AppScreen.addMedication)
              : () => showDataError('أضف مسناً قبل إضافة الدواء.'),
          onLogout: logout,
        ),
      AppScreen.caregiverAlerts => CaregiverAlerts(
          alerts: alerts,
          patientName: patientName,
          onBack: () => navigate(AppScreen.caregiverDashboard),
        ),
      AppScreen.addElderly => AddElderlyScreen(
          onBack: () => navigate(AppScreen.caregiverDashboard),
          onLink: linkElderlyByCode,
        ),
      AppScreen.addMedication => AddMedicationScreen(
          patientName: patientName,
          onBack: () => navigate(AppScreen.caregiverDashboard),
          onSave: addMedication,
        ),
    };

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: KeyedSubtree(key: ValueKey(screen), child: child),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget? _buildBottomNav() {
    if (role == UserRole.elderly &&
        {AppScreen.home, AppScreen.history, AppScreen.medicationDetail}
            .contains(screen)) {
      return BottomNav(
        items: [
          NavConfig(Icons.home_rounded, 'الرئيسية', AppScreen.home),
          NavConfig(
              Icons.medication_rounded, 'الأدوية', AppScreen.medicationDetail),
          NavConfig(Icons.history_rounded, 'المتابعة', AppScreen.history),
          NavConfig(Icons.health_and_safety_rounded, 'مساعدة', screen),
        ],
        current: screen,
        onNavigate: navigate,
      );
    }
    if (role == UserRole.caregiver &&
        {
          AppScreen.caregiverDashboard,
          AppScreen.caregiverAlerts,
          AppScreen.addElderly,
        }.contains(screen)) {
      return BottomNav(
        items: [
          NavConfig(
              Icons.home_rounded, 'الرئيسية', AppScreen.caregiverDashboard),
          NavConfig(Icons.person_add_rounded, 'إضافة', AppScreen.addElderly),
          NavConfig(Icons.chat_bubble_rounded, 'الاطمئنان', screen),
          NavConfig(
              Icons.warning_rounded, 'التنبيهات', AppScreen.caregiverAlerts),
        ],
        current: screen,
        onNavigate: navigate,
      );
    }
    return null;
  }

  Medication? _findMedicationById(List<Medication> items, String id) {
    for (final item in items) {
      if (item.id == id) return item;
    }
    return null;
  }

  ScheduledDose? _findDoseById(String id) {
    for (final dose in todayDoses) {
      if (dose.id == id) return dose;
    }
    return null;
  }

  ScheduledDose? _nextPendingDose() {
    final pending = todayDoses
        .where((item) => item.status == MedicationStatus.pending)
        .toList()
      ..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
    return pending.isEmpty ? null : pending.first;
  }

  static const _emptyMedication = Medication(
    id: '',
    name: 'لا يوجد دواء محدد',
    dosage: '',
    description: '',
    time: '',
    status: MedicationStatus.pending,
    category: '',
    instructions: [],
  );
}
