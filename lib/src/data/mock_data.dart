import '../models/activity_log.dart';
import '../models/activity_type.dart';
import '../models/medication.dart';
import '../models/medication_status.dart';

const mockMedications = <Medication>[
  Medication(
    id: '1',
    name: 'ليسينوبريل',
    dosage: 'قرص واحد',
    description: 'قرص أبيض مستدير 10 ملجم',
    time: '08:00 ص',
    status: MedicationStatus.pending,
    category: 'ضغط الدم',
    instructions: ['يؤخذ مع الطعام', 'كوب كامل من الماء'],
    image:
        'https://lh3.googleusercontent.com/aida-public/AB6AXuDYNDEaqPa9CZddbInulQ7CHoAhdAJnuKshcQtjP9AYzgdinSKKUJsCXLQDd3NIk4mO89B1deNlTrS4sfDQ3wmRB2eqV9e6TqdbSg1NpvBtX-8qHH7kLfw9hFPWvwHyJvlpXdeSG-duok2I9_fC2Ah9UGNbSfDpfyiJyzyM0pnO_l_9PEvonS-22mfiQa3srJYjFmoRgqMlXe_C9-soPxNNS9Cm4OnyM9hbWFqLTzMCxemNqXOqFnMTHWOodMEmjKLoEves6cToBY4',
  ),
  Medication(
    id: '2',
    name: 'ميتفورمين',
    dosage: 'قرص واحد',
    description: '٥٠٠ ملغ',
    time: '12:30 م',
    status: MedicationStatus.pending,
    category: 'السكري',
    instructions: ['يؤخذ بعد الأكل'],
  ),
  Medication(
    id: '3',
    name: 'فيتامين د٣',
    dosage: 'كبسولة واحدة',
    description: '١٠٠٠ وحدة دولية',
    time: '02:00 م',
    status: MedicationStatus.taken,
    category: 'مكمل غذائي',
    instructions: [],
  ),
];

const mockActivities = <ActivityLog>[
  ActivityLog(
    id: '1',
    type: ActivityType.checkIn,
    title: 'تم الاطمئنان',
    description: 'استطلاع صوتي آلي: "أشعر بخير"',
    time: '10:45 ص',
    user: 'آرثر ميلر',
  ),
  ActivityLog(
    id: '2',
    type: ActivityType.activity,
    title: 'رصد وجبة طعام',
    description: 'أجهزة المطبخ نشطة لمدة ٢٢ دقيقة',
    time: '08:15 ص',
    user: 'آرثر ميلر',
  ),
  ActivityLog(
    id: '3',
    type: ActivityType.sleep,
    title: 'انتهت دورة النوم',
    description: 'المدة الإجمالية: ٧س ٤٢د',
    time: '07:05 ص',
    user: 'آرثر ميلر',
  ),
];
