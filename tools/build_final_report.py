from pathlib import Path
import html
import zipfile


ROOT = Path(__file__).resolve().parents[1]
DOCX = ROOT / "Elderly_Companion_Final_Report_Draft.docx"


def esc(text):
    return html.escape(str(text), quote=False)


def r(text, bold=False, italic=False, size=22, color=None, rtl=False):
    props = []
    if bold:
        props.append("<w:b/>")
    if italic:
        props.append("<w:i/>")
    if size:
        props.append(f'<w:sz w:val="{size}"/><w:szCs w:val="{size}"/>')
    if color:
        props.append(f'<w:color w:val="{color}"/>')
    if rtl:
        props.append("<w:rtl/>")
    rpr = f"<w:rPr>{''.join(props)}</w:rPr>" if props else ""
    return f"<w:r>{rpr}<w:t xml:space=\"preserve\">{esc(text)}</w:t></w:r>"


def p(text="", style=None, bold=False, italic=False, size=22, color=None, align=None, before=0, after=120, rtl=False):
    ppr = []
    if style:
        ppr.append(f'<w:pStyle w:val="{style}"/>')
    if rtl:
        ppr.append("<w:bidi/>")
        align = align or "right"
    if align:
        ppr.append(f'<w:jc w:val="{align}"/>')
    if before or after:
        ppr.append(f'<w:spacing w:before="{before}" w:after="{after}"/>')
    ppr_xml = f"<w:pPr>{''.join(ppr)}</w:pPr>" if ppr else ""
    return f"<w:p>{ppr_xml}{r(text, bold=bold, italic=italic, size=size, color=color, rtl=rtl)}</w:p>"


def heading(text, level=1, rtl=False):
    if level == 1:
        return p(text, style="Heading1", bold=True, size=32, color="1F4E79", before=300, after=160, rtl=rtl)
    if level == 2:
        return p(text, style="Heading2", bold=True, size=28, color="2F75B5", before=220, after=120, rtl=rtl)
    return p(text, style="Heading3", bold=True, size=24, color="1F4E79", before=160, after=100, rtl=rtl)


def bullet(text):
    return p("- " + text, size=22, after=80)


def page_break():
    return '<w:p><w:r><w:br w:type="page"/></w:r></w:p>'


def table(rows, widths=None):
    if not rows:
        return ""
    cols = len(rows[0])
    if widths is None:
        widths = [int(9000 / cols)] * cols
    grid = "".join(f'<w:gridCol w:w="{w}"/>' for w in widths)
    out = [
        '<w:tbl>',
        '<w:tblPr><w:tblStyle w:val="TableGrid"/><w:tblW w:w="0" w:type="auto"/>'
        '<w:tblLook w:val="04A0" w:firstRow="1" w:lastRow="0" w:firstColumn="1" w:lastColumn="0" w:noHBand="0" w:noVBand="1"/>'
        '</w:tblPr>',
        f"<w:tblGrid>{grid}</w:tblGrid>",
    ]
    for i, row in enumerate(rows):
        out.append("<w:tr>")
        for j, cell in enumerate(row):
            fill = '<w:shd w:fill="D9EAF7"/>' if i == 0 else ""
            out.append(
                '<w:tc>'
                f'<w:tcPr><w:tcW w:w="{widths[j]}" w:type="dxa"/>{fill}'
                '<w:tcMar><w:top w:w="90" w:type="dxa"/><w:left w:w="120" w:type="dxa"/>'
                '<w:bottom w:w="90" w:type="dxa"/><w:right w:w="120" w:type="dxa"/></w:tcMar></w:tcPr>'
                f'{p(cell, bold=(i == 0), size=20, after=60)}'
                '</w:tc>'
            )
        out.append("</w:tr>")
    out.append("</w:tbl>")
    return "".join(out) + p("", after=120)


def section_props():
    return (
        '<w:sectPr>'
        '<w:pgSz w:w="11906" w:h="16838"/>'
        '<w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" w:header="720" w:footer="720" w:gutter="0"/>'
        '<w:cols w:space="720"/>'
        '<w:docGrid w:linePitch="360"/>'
        '</w:sectPr>'
    )


body = []

body += [
    p("Kingdom of Saudi Arabia", align="center", size=24, bold=True),
    p("Ministry of Education", align="center", size=24, bold=True),
    p("University of Hafr Al Batin", align="center", size=24, bold=True),
    p("College of Computer Science and Engineering", align="center", size=24, bold=True),
    p("Department of Computer Science and Engineering", align="center", size=24, bold=True),
    p("", after=500),
    p("Elderly Companion Application", align="center", size=40, bold=True, color="1F4E79"),
    p("Final Graduation Project Report", align="center", size=28, bold=True),
    p("Academic Year 2025-2026", align="center", size=24),
    p("", after=300),
    p("Supervisor: Dr. Asem Othman", align="center", size=24, bold=True),
    p("", after=160),
    p("Students", align="center", size=24, bold=True),
    table([
        ["Student Name", "Student ID"],
        ["Reham Radi", "2221006018"],
        ["Jawaher Alanzi", "2221003206"],
        ["Budor Alharbi", "2221002394"],
        ["Atheer Alshammari", "2221004670"],
        ["Rawan Almutairi", "2221002069"],
    ], [5000, 3000]),
    page_break(),
]

body += [
    heading("Abstract"),
    p("The Elderly Companion application is a mobile-based healthcare support system designed to help older adults manage medication routines while enabling caregivers to follow up with essential daily information. The implemented system provides user authentication, role-based access for elderly users and caregivers, caregiver-to-elderly account linking, medication scheduling, local medication reminders, daily dose tracking, check-in confirmation, missed-dose detection, caregiver alerts, recent activity tracking, and a daily follow-up report. The application was developed using Flutter for the mobile interface and Firebase services for authentication, cloud data storage, and notification readiness."),
    p("A key design decision in the final implementation is the separation between medication definitions and daily dose records. Each scheduled dose is tracked independently, allowing the elderly user to confirm, postpone, or miss a specific dose without affecting other doses of the same medication. If a dose remains unconfirmed beyond a predefined grace period, the system marks it as missed and creates an alert for the linked caregiver. The application also stores daily check-ins in Firestore, making the elderly user's interaction status persistent and available for caregiver follow-up."),
    p("The project focuses on practical usability and low-cost deployment by relying on widely available smartphones rather than mandatory external hardware. Although the system is designed to support future expansion with IoT devices and cloud-triggered push notifications, the current version implements the core mobile and Firebase-based functions needed for a functional minimum viable product."),
    heading("موجز المشروع باللغة العربية", rtl=True),
    p("يهدف تطبيق رفيق كبار السن إلى مساعدة كبار السن على الالتزام بمواعيد الأدوية وتسهيل متابعة مقدمي الرعاية لحالتهم اليومية. يوفر التطبيق تسجيل دخول آمن، وربطاً بين حساب المسن ومقدم الرعاية، وإدارة مواعيد الأدوية، وتذكيرات محلية، وسجلاً يومياً لكل جرعة، مع إمكانية تأكيد الجرعة أو تأجيلها. كما يقوم النظام بتحويل الجرعة إلى فائتة عند عدم تأكيدها بعد فترة سماح محددة، ثم إنشاء تنبيه لمقدم الرعاية.", rtl=True),
    p("يعتمد التطبيق على Flutter في الواجهة الأمامية وعلى Firebase في المصادقة وتخزين البيانات. تم تصميم النظام ليكون بسيطاً ومناسباً للمسنين، مع توفير لوحة متابعة لمقدم الرعاية تعرض التنبيهات والنشاطات والتقارير اليومية. لا تتطلب النسخة الحالية أجهزة ذكية خارجية، لكنها تترك مجالاً للتوسع مستقبلاً من خلال تكامل إنترنت الأشياء أو خدمات إشعارات سحابية أكثر تقدماً.", rtl=True),
    page_break(),
]

body += [
    heading("Table of Contents"),
    p("1. Introduction"),
    p("2. Background"),
    p("3. Problem Description and Motivation"),
    p("4. Digitization and Vision 2030"),
    p("5. Literature Review"),
    p("6. Requirements"),
    p("7. Project Scope"),
    p("8. Project Management Strategy"),
    p("9. Materials and Methods"),
    p("10. Design Overview"),
    p("11. Developer Perspective"),
    p("12. User Perspective"),
    p("13. System Diagrams"),
    p("14. Results and Discussion"),
    p("15. Conclusions and Future Work"),
    p("16. References"),
    page_break(),
]

body += [
    heading("1. Introduction"),
    p("The increasing number of elderly individuals living independently has created a need for practical digital tools that support medication adherence and routine follow-up. Older adults may forget medication times, postpone doses without recording them, or miss daily communication with family members. These situations can increase health risk and create anxiety for caregivers."),
    p("The Elderly Companion application addresses this problem through a mobile system that combines medication scheduling, local reminders, daily dose confirmation, check-in functionality, and caregiver monitoring. The system is intentionally designed around essential workflows rather than complex medical features, making it suitable as a practical graduation project and as a foundation for future healthcare extensions."),
    heading("2. Background"),
    p("Medication adherence is a major concern in elderly healthcare, especially for users who manage multiple medications at different times of the day. Traditional reminders such as paper notes or phone calls are useful but difficult to track automatically. Mobile applications provide a more structured solution because they can store schedules, display reminders, record interactions, and synchronize data with caregivers."),
    p("In this project, the smartphone acts as the primary platform. The elderly user receives medication reminders and confirms or postpones doses, while the caregiver monitors alerts, recent activity, and daily reports. The implementation avoids requiring specialized hardware, which supports accessibility and reduces deployment cost."),
    heading("3. Problem Description and Motivation"),
    p("The project is motivated by three related problems. First, elderly users may miss medication doses due to memory limitations or complex routines. Second, caregivers need timely information but cannot always be physically present. Third, many existing solutions are either too complex for elderly users or focus only on reminders without caregiver escalation."),
    p("The implemented application responds to these problems by recording each scheduled dose independently and by escalating missed doses to caregivers. It also includes a daily check-in mechanism to provide a simple interaction signal indicating that the elderly user has engaged with the application during the day."),
    heading("4. Digitization and Vision 2030"),
    p("The project aligns with Saudi Arabia's Vision 2030 by supporting digital transformation in healthcare-related services. It converts manual medication follow-up into a structured digital workflow and demonstrates how mobile applications can improve quality of life for older adults while reducing the monitoring burden on families."),
    p("The solution also supports scalability. While the current implementation focuses on mobile and Firebase services, its data model and architecture can be extended to include wearable sensors, fall detection systems, or health monitoring devices in future work."),
]

body += [
    heading("5. Literature Review"),
    p("Research on mobile health applications indicates that reminders, tracking, and feedback mechanisms can improve medication adherence. Studies also highlight the importance of usability for older adults. Interfaces designed for elderly users should minimize steps, use clear visual hierarchy, and avoid overwhelming the user with unnecessary data."),
    p("Existing applications such as Medisafe, CareZone, and MyTherapy provide medication management features, but caregiver integration and inactivity-based monitoring may vary between systems. The Elderly Companion project focuses on a balanced scope: medication scheduling, dose-level tracking, caregiver alerts, and simple check-in monitoring."),
    heading("6. Requirements"),
    heading("6.1 Hardware Requirements", 2),
    bullet("A smartphone for the elderly user capable of running the Flutter application."),
    bullet("A smartphone or internet-enabled device for the caregiver."),
    bullet("Internet connectivity for authentication, synchronization, and caregiver monitoring."),
    bullet("Optional future support for wearable or IoT devices such as heart-rate bands, fall detectors, or blood pressure/glucose monitors."),
    heading("6.2 Software Requirements", 2),
    table([
        ["Requirement", "Implemented Technology"],
        ["Mobile framework", "Flutter and Dart"],
        ["Authentication", "Firebase Authentication"],
        ["Cloud database", "Cloud Firestore"],
        ["Medication reminders", "flutter_local_notifications with timezone scheduling"],
        ["Notification readiness", "Firebase Messaging token registration"],
        ["Security", "Firestore security rules and authenticated access"],
    ], [3000, 6000]),
    heading("6.3 User Requirements", 2),
    bullet("Elderly users need a simple interface for viewing today's doses, confirming medication intake, postponing doses, and performing daily check-in."),
    bullet("Caregivers need a dashboard to view linked elderly users, alerts, and recent activity."),
    bullet("The system must preserve basic privacy by storing only necessary operational data."),
    heading("6.4 Data Requirements", 2),
    table([
        ["Data Entity", "Purpose"],
        ["Users", "Stores profile, role, linked caregiver/elderly IDs, and messaging tokens."],
        ["Medications", "Stores medication name, dosage, notes, schedule times, and start date."],
        ["Dose Logs", "Stores the daily status of each scheduled dose."],
        ["Check-ins", "Stores daily confirmation that the elderly user is okay."],
        ["Alerts", "Stores caregiver alerts for missed doses and future monitoring events."],
        ["Activity Logs", "Stores recent user actions for caregiver review."],
    ], [2500, 6500]),
]

body += [
    heading("7. Project Scope"),
    p("The project scope is limited to a mobile application that supports medication adherence and caregiver follow-up. It includes user authentication, role-based interfaces, caregiver linking, medication scheduling, local reminders, dose-level tracking, check-in storage, missed-dose escalation, caregiver alerts, and a daily report."),
    table([
        ["In Scope", "Out of Scope / Future Work"],
        ["Medication scheduling with multiple daily times.", "Clinical diagnosis or medical decision-making."],
        ["Local medication reminders on the elderly user's device.", "Full server-side push notification automation using Cloud Functions."],
        ["Daily dose logs with taken, postponed, missed, and pending states.", "Integration with wearable sensors or IoT medical devices."],
        ["Caregiver dashboard, alerts, and recent activity.", "Advanced analytics and long-term trend prediction."],
        ["Daily check-in saved in Firestore.", "Hospital or national health-system integration."],
    ], [4500, 4500]),
    heading("8. Project Management Strategy"),
    p("The project was developed iteratively. The initial stage focused on defining the problem, reviewing existing solutions, and identifying the main system requirements. The implementation stage was divided into authentication, caregiver linking, medication management, dose tracking, notifications, alerts, and reporting. Testing was performed incrementally after each functional module to verify behavior before adding the next feature."),
    heading("8.1 Team Roles", 2),
    p("The following table can be updated by the team to reflect the exact contribution of each member before final submission."),
    table([
        ["Team Member", "Suggested Role / Contribution"],
        ["Reham Radi", "Requirements analysis, report writing, and testing."],
        ["Jawaher Alanzi", "UI/UX review, caregiver workflow, and documentation."],
        ["Budor Alharbi", "Medication workflow, testing scenarios, and results section."],
        ["Atheer Alshammari", "Firebase data model, diagrams, and technical documentation."],
        ["Rawan Almutairi", "Presentation preparation, references, and final proofreading."],
    ], [3500, 5500]),
    heading("8.2 Time Plan", 2),
    table([
        ["Phase", "Main Activities"],
        ["Planning", "Problem definition, objectives, literature review, requirement collection."],
        ["Design", "UI/UX sketches, data model, use cases, and system architecture."],
        ["Implementation", "Flutter screens, Firebase authentication, Firestore repositories, reminders, alerts."],
        ["Testing", "Functional testing for login, linking, medication creation, reminders, dose status, alerts, and reports."],
        ["Finalization", "Final report, diagrams, presentation, and future work documentation."],
    ], [3000, 6000]),
]

body += [
    heading("9. Materials and Methods"),
    table([
        ["Item", "Description"],
        ["Operating System", "Windows development environment with Android emulator/device support."],
        ["Development IDE", "Visual Studio Code and Android/Flutter tooling."],
        ["Programming Language", "Dart."],
        ["Framework", "Flutter cross-platform mobile framework."],
        ["Backend Services", "Firebase Authentication, Cloud Firestore, Firebase Messaging readiness."],
        ["Database", "Cloud Firestore document database."],
        ["Notifications", "Local notifications for medication reminders; caregiver notification readiness through FCM tokens and local alert display."],
        ["Documentation", "Graduation project report, system diagrams, and testing notes."],
    ], [3000, 6000]),
    heading("10. Design Overview"),
    heading("10.1 UI/UX Design Direction", 2),
    p("The user interface was designed to support elderly users through clear visual hierarchy, large action buttons, simple Arabic labels, and right-to-left layout. The caregiver interface uses a dashboard structure to show linked elderly users, alerts, and recent activity in a direct and readable format."),
    heading("10.2 Screenshots to Add", 2),
    p("The following screenshots should be inserted by the team in this section. Each screenshot should include a short caption explaining what the screen demonstrates."),
    table([
        ["Screenshot", "Purpose"],
        ["Login screen", "Shows authentication entry point."],
        ["Sign-up screen with role selection", "Shows how users choose elderly or caregiver role."],
        ["Elderly home screen", "Shows daily check-in, today's doses, and care link code."],
        ["Add medication screen", "Shows medication name, dosage, date picker, and time picker."],
        ["Medication detail screen", "Shows medication schedule and dose confirmation actions."],
        ["History/report screen", "Shows adherence percentage, dose records, and report button."],
        ["Caregiver dashboard", "Shows linked elderly users, alerts summary, and recent activity."],
        ["Add elderly screen", "Shows linking process using care code."],
        ["Caregiver alerts screen", "Shows missed-dose alert display."],
        ["Daily report dialog", "Shows generated follow-up report inside the app."],
    ], [3500, 5500]),
]

body += [
    heading("11. Developer Perspective"),
    p("The application follows a modular Flutter structure. Screens handle user interaction, widgets provide reusable UI components, repositories encapsulate Firestore operations, and services handle authentication, local notifications, and messaging readiness. This separation improves maintainability and allows future features to be added without rewriting the entire application."),
    table([
        ["Layer", "Examples"],
        ["Models", "AppUser, Medication, DoseLog, ScheduledDose, CheckIn, CaregiverAlert."],
        ["Repositories", "UserRepository, MedicationRepository, DoseLogRepository, CheckInRepository, AlertRepository, ActivityRepository."],
        ["Services", "AuthService, NotificationService, MessagingService."],
        ["Screens", "HomeScreen, AddMedicationScreen, HistoryScreen, CaregiverDashboard, CaregiverAlerts."],
        ["Widgets", "MedicationCard, HistoryItem, AlertCard, BottomNav, layout and form widgets."],
    ], [2500, 6500]),
    p("A major technical improvement in the final implementation is dose-level tracking. Instead of storing only one status per medication, each scheduled dose is represented as a daily ScheduledDose and stored as a DoseLog when the user confirms, postpones, or misses it. This design better matches real medication routines where one medication may have multiple daily doses."),
    heading("12. User Perspective"),
    p("From the elderly user's perspective, the system starts with a simple login process and a home screen showing daily check-in and today's medication doses. The user can confirm that they are okay, view upcoming doses, and mark each dose as taken or postponed. The interface avoids complex navigation and uses large controls suitable for repeated daily use."),
    p("From the caregiver's perspective, the system provides a dashboard for linked elderly users. The caregiver can add an elderly user using a care link code, view recent activity, add medications, and monitor alerts. When a dose becomes missed after the grace period, an alert is created and displayed to the caregiver."),
]

body += [
    heading("13. System Diagrams"),
    p("The final report should include diagrams based on the implemented system. The following descriptions define what each diagram should represent."),
    heading("13.1 Entity Relationship Diagram", 2),
    p("The ER diagram should include Users, Medications, DoseLogs, CheckIns, Alerts, ActivityLogs, and CareLinkCodes. The Users entity supports both elderly and caregiver roles. Medications, dose logs, check-ins, alerts, and activity logs are stored under the elderly user's Firestore document."),
    heading("13.2 Use Case Diagram", 2),
    p("Actors: Elderly User and Caregiver. Main use cases: sign up, login, link caregiver to elderly, add medication, view today's doses, confirm dose, postpone dose, perform check-in, view history/report, view alerts, and view activity."),
    heading("13.3 Activity Diagram", 2),
    p("The activity diagram should show the medication flow: caregiver or elderly adds medication, app schedules reminder, elderly receives reminder, elderly confirms or postpones dose, system records dose log, and if no action is taken after the grace period, the dose becomes missed and an alert is generated."),
    heading("13.4 Sequence Diagram", 2),
    p("The sequence diagram should focus on missed-dose escalation: Flutter app reads today's doses, DoseLogRepository detects overdue pending dose, Firestore stores missed dose log, AlertRepository creates caregiver alert, caregiver dashboard receives the alert stream."),
    heading("13.5 Class Diagram", 2),
    p("The class diagram should show the main model, repository, and service classes: AppUser, Medication, DoseLog, ScheduledDose, CheckIn, CaregiverAlert, AuthService, NotificationService, MessagingService, and the repository classes."),
    heading("13.6 Dataflow, Network, and Framework Diagrams", 2),
    p("The dataflow diagram should show Flutter screens interacting with repositories, repositories communicating with Firebase Auth and Firestore, and notifications being handled through local notification services and messaging readiness. The network/framework diagram should show mobile clients connected to Firebase cloud services."),
]

body += [
    heading("14. Results and Discussion"),
    p("The implemented system achieved the main functional goals of the project. The application supports user registration and login, role-based access, caregiver linking, medication scheduling with multiple times, local reminders, daily dose tracking, check-in storage, missed-dose detection, caregiver alerts, activity logs, and a daily report."),
    table([
        ["Project Objective", "Implementation Status"],
        ["Support medication reminders", "Implemented through local scheduled notifications."],
        ["Allow elderly user to confirm or postpone a dose", "Implemented at individual dose level using DoseLog records."],
        ["Maintain medication history", "Implemented through daily dose logs and activity logs."],
        ["Notify caregiver about missed medication", "Implemented through Firestore caregiver alerts; FCM token readiness added."],
        ["Support daily check-in", "Implemented and stored in Firestore by date."],
        ["Provide caregiver monitoring", "Implemented through dashboard, linked elderly list, alerts, and recent activity."],
        ["Support future IoT integration", "Not implemented; architecture leaves room for future extension."],
    ], [4000, 5000]),
    heading("14.1 Implemented Outputs", 2),
    bullet("A Flutter mobile application with Arabic right-to-left interface."),
    bullet("Firebase Authentication for secure user accounts."),
    bullet("Firestore collections for users, medications, daily dose logs, check-ins, alerts, and activity logs."),
    bullet("Medication reminders and dose-level status updates."),
    bullet("Caregiver alerts generated when a dose becomes missed."),
    bullet("A daily report dialog summarizing adherence and dose status."),
    heading("14.2 Limitations", 2),
    bullet("Full cloud push notification delivery when the caregiver app is completely closed requires a Cloud Function or backend service."),
    bullet("Inactivity alerting based on missing daily check-in is prepared by persistent check-in storage but should be automated in future work."),
    bullet("IoT device integration is not part of the current implementation."),
    bullet("The report is displayed inside the application; exporting to PDF or sharing a file can be added later."),
]

body += [
    heading("15. Conclusions and Future Work"),
    p("The Elderly Companion application demonstrates a practical mobile solution for supporting elderly medication adherence and caregiver follow-up. The system implements core workflows required for a minimum viable product, including scheduled medication management, daily dose tracking, missed-dose escalation, daily check-in, caregiver dashboard, and reporting. By separating medication definitions from daily dose logs, the application provides a more accurate representation of real medication behavior."),
    p("Future work should focus on backend automation and richer monitoring. A Firebase Cloud Function can be added to send push notifications to caregiver devices even when the application is closed. Inactivity alerts can be automated by checking whether a daily check-in has been recorded by a specific time. Additional improvements may include PDF report export, analytics dashboards, multilingual support, and integration with IoT health devices such as fall detectors or heart-rate sensors."),
    heading("16. References"),
    p("[1] World Health Organization, Adherence to Long-Term Therapies: Evidence for Action, Geneva, Switzerland, 2003."),
    p("[2] K. Santo, C. Richtering, J. Chalmers, et al., \"Mobile phone apps to improve medication adherence: A systematic review and meta-analysis,\" Journal of Medical Internet Research, vol. 18, no. 6, 2016."),
    p("[3] C. Free, G. Phillips, L. Galli, et al., \"The effectiveness of mobile-health technologies to improve health care service delivery processes: A systematic review,\" PLoS Medicine, vol. 10, no. 1, 2013."),
    p("[4] N. Noury, A. Fleury, P. Rumeau, et al., \"Fall detection - Principles and methods,\" Proceedings of the IEEE Engineering in Medicine and Biology Society, 2007."),
    p("[5] P. Rashidi and A. Mihailidis, \"A survey on ambient-assisted living tools for older adults,\" IEEE Journal of Biomedical and Health Informatics, vol. 17, no. 3, 2013."),
    p("[6] D. Zhang, H. Wang, and R. Wang, \"IoT-based healthcare monitoring systems: A review,\" Sensors, vol. 20, no. 12, 2020."),
    p("[7] A. Holzinger, \"User-centered design in elderly healthcare applications,\" Universal Access in Human-Computer Interaction, 2013."),
    p("[8] S. J. Czaja, C. C. Lee, et al., \"Factors predicting the use of technology,\" Psychology and Aging, vol. 21, no. 2, 2006."),
    p("[9] Medisafe, \"Medication Management App,\" [Online]. Available: https://www.medisafeapp.com"),
    p("[10] CareZone, \"Medication and Health Management App,\" [Online]. Available: https://carezone.com/"),
    p("[11] MyTherapy, \"Pill Reminder and Medication Tracker,\" [Online]. Available: https://www.mytherapyapp.com"),
    heading("Biography"),
    p("Student and advisor biography details should be completed by the team according to the university template before final submission."),
]


document_xml = (
    '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
    '<w:document xmlns:wpc="http://schemas.microsoft.com/office/word/2010/wordprocessingCanvas" '
    'xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006" '
    'xmlns:o="urn:schemas-microsoft-com:office:office" '
    'xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships" '
    'xmlns:m="http://schemas.openxmlformats.org/officeDocument/2006/math" '
    'xmlns:v="urn:schemas-microsoft-com:vml" '
    'xmlns:wp14="http://schemas.microsoft.com/office/word/2010/wordprocessingDrawing" '
    'xmlns:wp="http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing" '
    'xmlns:w10="urn:schemas-microsoft-com:office:word" '
    'xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" '
    'xmlns:w14="http://schemas.microsoft.com/office/word/2010/wordml" '
    'xmlns:wpg="http://schemas.microsoft.com/office/word/2010/wordprocessingGroup" '
    'xmlns:wpi="http://schemas.microsoft.com/office/word/2010/wordprocessingInk" '
    'xmlns:wne="http://schemas.microsoft.com/office/word/2006/wordml" '
    'xmlns:wps="http://schemas.microsoft.com/office/word/2010/wordprocessingShape" '
    'mc:Ignorable="w14 wp14">'
    '<w:body>'
    + "".join(body)
    + section_props()
    + '</w:body></w:document>'
)


tmp = DOCX.with_suffix(".tmp.docx")
with zipfile.ZipFile(DOCX, "r") as zin, zipfile.ZipFile(tmp, "w", zipfile.ZIP_DEFLATED) as zout:
    for item in zin.infolist():
        data = zin.read(item.filename)
        if item.filename == "word/document.xml":
            data = document_xml.encode("utf-8")
        zout.writestr(item, data)

tmp.replace(DOCX)
print(DOCX)
